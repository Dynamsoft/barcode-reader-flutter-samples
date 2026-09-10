import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarcodeReaderSettings',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CaptureVisionRouter _cvr = CaptureVisionRouter();
  final CameraEnhancer _camera = CameraEnhancer();
  final String _templateName = EnumPresetTemplate.readBarcodes;
  bool _isDisposed = false;
  String _resultsText = '';
  int _resultCount = 0;

  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onDecodedBarcodesReceived = (DecodedBarcodesResult result) async {
      if (result.items?.isNotEmpty ?? false) {
        final items = result.items!;
        final text = items
            .asMap()
            .entries
            .map(
              (entry) =>
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
    PermissionUtil.requestCameraPermission();
    // Initialize the license.
    // The license string here is a trial license. Note that network connection is required for this license to work.
    // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=flutter
    LicenseManager.initLicense('DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9').then(
      (data) {
        final (isSuccess, message) = data;
        if (!isSuccess) {
          debugPrint('license error: $message');
        }
      },
    );
    initSdk();
  }

  void initSdk() async {
    await _cvr.setInput(_camera);
    _cvr.addResultReceiver(_receiver);
    // update settings before starting scanning if needed.
    // updateSettings();
    await _startScanning();
  }

  void updateSettings() async {
    try {
      final settings = await _cvr.getSimplifiedSettings(_templateName);
      if (settings == null) {
        _showTextDialog('Settings Error', 'Failed to get settings.');
        return;
      }
      // Modify the settings as needed

      // barcode format
      settings.barcodeSettings?.barcodeFormatIds = EnumBarcodeFormat.all;

      // expected barcodes count
      settings.barcodeSettings?.expectedBarcodesCount = 0;

      // minimum result confidence
      settings.barcodeSettings?.minResultConfidence = 30;

      // scale down threshold
      settings.barcodeSettings?.scaleDownThreshold = 1200;

      // minimum barcode text length
      settings.barcodeSettings?.minBarcodeTextLength = 0;

      // timeout
      settings.timeout = 500;

      // minimum image capture interval
      settings.minImageCaptureInterval = 100;
      await _cvr.updateSettings(_templateName, settings);
    } catch (e) {
      _showTextDialog('Settings Error', e.toString());
    }
  }

  Future<void> _startScanning() async {
    if (_isDisposed) {
      return;
    }

    try {
      await _camera.open();
      await _cvr.startCapturing(_templateName);
    } catch (e) {
      _showTextDialog('Start Error', e.toString());
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

  void _showTextDialog(String title, String message) {
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
    super.dispose();

    _stopScanning();
    _cvr.removeResultReceiver(_receiver);
    _cvr.dispose();
    _camera.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _resultsText.isEmpty
                        ? 'Waiting for barcode...'
                        : _resultsText,
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
