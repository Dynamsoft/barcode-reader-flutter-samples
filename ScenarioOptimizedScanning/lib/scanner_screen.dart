import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String _license = 'DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.templateFile});

  final String templateFile;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final CaptureVisionRouter _cvr = CaptureVisionRouter();
  final CameraEnhancer _camera = CameraEnhancer();
  bool _isDisposed = false;
  String _resultsText = '';
  int _resultCount = 0;

  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onDecodedBarcodesReceived = (DecodedBarcodesResult result) async {
      if (result.items?.isNotEmpty ?? false) {
        final List<BarcodeResultItem> items = result.items!;
        final String text = items
            .asMap()
            .entries
            .map(
              (MapEntry<int, BarcodeResultItem> entry) =>
                  '${entry.key + 1}. Format: ${entry.value.formatString}\n    Text: ${entry.value.text}',
            )
            .join('\n\n');

        if (!_isDisposed && mounted) {
          setState(() {
            _resultCount = items.length;
            _resultsText = text;
          });
        }
      }
    };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await PermissionUtil.requestCameraPermission();

    final (bool isSuccess, String? message) =
        await LicenseManager.initLicense(_license);
    if (!isSuccess) {
      _showError('License error', message ?? 'Unknown license error.');
    }

    await _cvr.setInput(_camera);
    _cvr.addResultReceiver(_receiver);

    if (widget.templateFile.isNotEmpty) {
      try {
        final templateContent = await rootBundle.loadString('assets/Templates/${widget.templateFile}');
        await _cvr.initSettings(templateContent);
      } catch (e) {
        _showError('Load template error', e.toString());
      }
    } else {
      //When no template file is provided, use default settings
      await _cvr.resetSettings();
    }

    if (widget.templateFile == 'ReadDotCode.json') {
      await _camera.setScanRegion(
        DSRect(
          left: 0.15,
          top: 0.35,
          right: 0.85,
          bottom: 0.48,
          measuredInPercentage: true,
        ),
      );
      await _camera.setZoomFactor(3.0);
    }

    if (widget.templateFile == 'ReadPDF417.json') {
      await _camera.setResolution(EnumResolution.uhd4k);
    }

    await _startScanning();
  }

  Future<void> _startScanning() async {
    if (_isDisposed) {
      return;
    }

    try {
      await _camera.open();
      final String templateName = widget.templateFile.isEmpty
          ? EnumPresetTemplate.readBarcodes
          : '';
      await _cvr.startCapturing(templateName);
    } catch (e) {
      _showError('Start error', e.toString());
    }
  }

  Future<void> _stopScanning() async {
    try {
      await _cvr.stopCapturing();
    } catch (_) {}

    try {
      await _camera.close();
    } catch (_) {}
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
    _cvr.dispose();
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF151517),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: CameraView(cameraEnhancer: _camera)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withAlpha(179),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              constraints: const BoxConstraints(minHeight: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Total Results: $_resultCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultsText.isEmpty ? 'Waiting for barcode...' : _resultsText,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
