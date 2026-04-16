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
      title: 'ScanBarcodes',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: 'ScanBarcodes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CaptureVisionRouter _cvr = CaptureVisionRouter.instance;
  final CameraEnhancer _camera = CameraEnhancer.instance;
  final String _templateName = EnumPresetTemplate.readBarcodes;
  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onDecodedBarcodesReceived = (DecodedBarcodesResult result) async {
      if (result.items?.isNotEmpty ?? false) {
        _cvr.stopCapturing();
        var displayString = result.items?.map((item) => "Format: ${item.formatString}\nText: ${item.text}").join('\n\n');
        showTextDialog("Barcodes Count: ${result.items?.length ?? 0}", displayString ?? "", () {
          _cvr.startCapturing(_templateName);
        });
      }
    };

  @override
  void initState() {
    super.initState();
    PermissionUtil.requestCameraPermission();
    // Initialize the license.
    // The license string here is a trial license. Note that network connection is required for this license to work.
    // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=flutter
    LicenseManager.initLicense('DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9').then((data) {
      final (isSuccess, message) = data;
      if (!isSuccess) {
        print("license error: $message");
      }
    });
    initSdk();
  }

  void initSdk() async {
    await _cvr.setInput(_camera);
    _cvr.addResultReceiver(_receiver);
    _camera.open();
    try {
      await _cvr.startCapturing(_templateName);
    } catch (e) {
      showTextDialog("StartCapturing Error", e.toString(), null);
    }
  }

  void showTextDialog(String title, String message, VoidCallback? onDismiss) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text(title), content: Text(message));
      },
    ).then((_) {
      //Callback when dialog dismissed
      onDismiss?.call();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cvr.stopCapturing();
    _camera.close();
    _cvr.removeResultReceiver(_receiver);
    _cvr.dispose();
    _camera.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(child: CameraView(cameraEnhancer: _camera)),
    );
  }
}
