import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:flutter/material.dart';
import './parsed_util.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kLicense = 'DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final CaptureVisionRouter _cvr = CaptureVisionRouter();
  final CameraEnhancer _camera = CameraEnhancer();
  final String _templateName = 'ReadGS1AI';

  bool _isDialogShowing = false;
  bool _isDisposed = false;

  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onParsedResultsReceived = (ParsedResult result) async {
      final item = result.items?.isNotEmpty == true ? result.items!.first : null;
      if (item == null || _isDialogShowing || _isDisposed) {
        return;
      }

      _isDialogShowing = true;
      await _cvr.stopCapturing();
      final msg = buildGS1Message(item);

      if (!mounted) {
        _isDialogShowing = false;
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: const Text('GS1 Result'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      _isDialogShowing = false;
      await _startScanning();
    };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await PermissionUtil.requestCameraPermission();

    final (isSuccess, message) = await LicenseManager.initLicense(kLicense);
    if (!isSuccess && mounted) {
      _showError('License error', message ?? 'unknown error');
    }

    try {
      await _cvr.setInput(_camera);
      final templateContent = await rootBundle.loadString('assets/ReadGS1AI.json');
      await _cvr.initSettings(templateContent);
    } catch (e) {
      if (mounted) {
        _showError('Settings error', e.toString());
      }
    }

    await _cvr.addResultReceiver(_receiver);
    await _startScanning();
  }

  Future<void> _startScanning() async {
    if (_isDisposed) {
      return;
    }
    try {
      await _camera.open();
      await _cvr.startCapturing(_templateName);
    } catch (e) {
      if (mounted) {
        _showError('Start error', e.toString());
      }
    }
  }

  Future<void> _stopScanning() async {
    try {
      await _cvr.stopCapturing();
      await _camera.close();
    } catch (_) {
      // Ignore stop/close errors during lifecycle transitions.
    }
  }

  void _showError(String title, String message) {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
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
      body: SizedBox.expand(
        child: CameraView(cameraEnhancer: _camera),
      ),
    );
  }
}
