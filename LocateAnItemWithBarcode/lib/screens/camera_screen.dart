import 'dart:math';

import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:flutter/material.dart';

import '../scan_result_delegate.dart';

const String _license = 'DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9';
bool _licenseInitialized = false;

Future<void> _ensureLicenseInitialized() async {
  if (_licenseInitialized) {
    return;
  }
  final (bool isSuccess, String? message) = await LicenseManager.initLicense(_license);
  if (!isSuccess) {
    throw Exception(message ?? 'License error');
  }
  _licenseInitialized = true;
}

enum CameraMode { scan, search }

class CameraScreenArgs {
  final CameraMode mode;
  final String? targetText;

  const CameraScreenArgs({required this.mode, this.targetText});
}

class OverlayArc {
  final double x;
  final double y;
  final String symbol;
  final bool isMatch;
  final String? barcodeText;

  const OverlayArc({
    required this.x,
    required this.y,
    required this.symbol,
    required this.isMatch,
    this.barcodeText,
  });
}

class CameraScreen extends StatefulWidget {
  static const String routeName = '/camera';

  final CameraScreenArgs args;

  const CameraScreen({super.key, required this.args});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CaptureVisionRouter _cvr = CaptureVisionRouter();
  final CameraEnhancer _camera = CameraEnhancer();
  final MultiFrameResultCrossFilter _filter = MultiFrameResultCrossFilter();

  bool _isDisposed = false;
  bool _hasReturned = false;
  bool _isTargetFound = false;
  List<OverlayArc> _overlayArcs = <OverlayArc>[];

  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onDecodedBarcodesReceived = _onDecodedBarcodesReceived;

  CameraMode get _mode => widget.args.mode;

  String? get _targetText => widget.args.targetText;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await PermissionUtil.requestCameraPermission();
      await _ensureLicenseInitialized();
      await _cvr.setInput(_camera);

      await _filter.enableLatestOverlapping(EnumCapturedResultItemType.barcode.value, true);
      await _filter.setMaxOverlappingFrames(EnumCapturedResultItemType.barcode.value, 10);
      await _cvr.addResultFilter(_filter);
      await _cvr.addResultReceiver(_receiver);

      if (_mode == CameraMode.search) {
        await _cvr.initSettingsFromFile('ReadMultipleBarcodes.json');
      }

      await _startScanning();
    } catch (e) {
      _showError('Start error', e.toString());
    }
  }

  Future<void> _startScanning() async {
    final String templateName =
        _mode == CameraMode.search ? 'ReadMultipleBarcodes' : EnumPresetTemplate.readBarcodes;

    await _camera.open();
    if (_mode != CameraMode.search) {
      await _cvr.resetSettings();
    }
    await _cvr.startCapturing(templateName);
  }

  Future<void> _stopScanning() async {
    try {
      await _cvr.stopCapturing();
    } catch (_) {}

    try {
      await _camera.close();
    } catch (_) {}
  }

  Future<void> _onDecodedBarcodesReceived(DecodedBarcodesResult result) async {
    if (_isDisposed) {
      return;
    }

    final List<BarcodeResultItem> items = result.items ?? <BarcodeResultItem>[];

    if (_mode == CameraMode.scan) {
      if (items.isNotEmpty && !_hasReturned) {
        _hasReturned = true;
        await FeedBack.beep();
        notifyScanResult(items.first.text);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
      return;
    }

    if (items.isEmpty) {
      if (mounted) {
        setState(() {
          _overlayArcs = <OverlayArc>[];
          _isTargetFound = false;
        });
      }
      return;
    }

    final List<OverlayArc> arcs = <OverlayArc>[];
    bool found = false;

    for (final BarcodeResultItem item in items) {
      final Point<int> center = item.location.centrePoint();
      final Point<double> viewPoint = await _camera.convertPointToViewCoordinates(center);
      final bool isMatch = item.text == _targetText;
      if (isMatch) {
        found = true;
      }

      arcs.add(
        OverlayArc(
          x: viewPoint.x,
          y: viewPoint.y,
          symbol: isMatch ? '+' : '✕',
          isMatch: isMatch,
          barcodeText: isMatch ? item.text : null,
        ),
      );
    }

    // Sort arcs so that matched items are rendered last.
    // This ensures the matched barcode's decodeText is drawn on top
    // and not covered by unmatched arcs.
    arcs.sort((OverlayArc a, OverlayArc b) {
      if (a.isMatch == b.isMatch) return 0;
      return a.isMatch ? 1 : -1;
    });

    if (mounted) {
      setState(() {
        _overlayArcs = arcs;
        _isTargetFound = found;
      });
    }
  }

  void _showError(String title, String message) {
    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text(title), content: Text(message));
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopScanning();
    _cvr.removeResultReceiver(_receiver);
    _cvr.removeResultFilter(_filter);
    _filter.destroy();
    _cvr.dispose();
    _camera.dispose();
    setScanResultDelegate(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locate Item'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF333333),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CameraView(
              cameraEnhancer: _camera,
              torchButtonVisible: true,
              visibleLayerIds: const <EnumDrawingLayerId>[],
            ),
          ),
          if (_mode == CameraMode.search)
            ..._overlayArcs.expand(
                  (OverlayArc arc) {
                final Color color = arc.isMatch ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
                return <Widget>[
                  Positioned(
                    left: arc.x - 10,
                    top: arc.y - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        arc.symbol,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (arc.isMatch && arc.barcodeText != null)
                    Positioned(
                      left: arc.x - 80,
                      top: arc.y + 10,
                      width: 160,
                      child: Text(
                        arc.barcodeText!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ];
              },
            ),
          if (_mode == CameraMode.search)
            Positioned(
              top: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'Locate another item',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          if (_mode == CameraMode.search)
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: _isTargetFound ? const Color.fromRGBO(76, 175, 80, 0.9) : const Color.fromRGBO(0, 0, 0, 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  _isTargetFound
                      ? '✓ Item Found: "${_targetText ?? ''}"'
                      : 'Searching for: "${_targetText ?? ''}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
