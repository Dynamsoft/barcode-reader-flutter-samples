import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:flutter/material.dart';

import 'driver_license_scan_result.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with RouteAware {
  final CaptureVisionRouter _cvr = CaptureVisionRouter.instance;
  final CameraEnhancer _camera = CameraEnhancer.instance;
  final String _templateName = "ReadDriversLicense";
  late final CapturedResultReceiver _receiver = CapturedResultReceiver()
    ..onParsedResultsReceived = (ParsedResult result) async {
      if (result.items?.isNotEmpty ?? false) {
        _cvr.stopCapturing();
        final data = DriverLicenseData.fromParsedResultItem(result.items![0]);
        if (data != null) {
          final scanResult = DriverLicenseScanResult(resultStatus: EnumResultStatus.finished, data: data);
          Navigator.pop(context, scanResult);
        } else {
          _cvr.startCapturing(_templateName); // restart capturing
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
      Navigator.of(context).pop(
        DriverLicenseScanResult(
          resultStatus: EnumResultStatus.error,
          errorString: e.toString(),
        )
      );
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:  (bool didPop, Object? _) {
        if (didPop) {
          return;
        }
        final scanResult = DriverLicenseScanResult(resultStatus: EnumResultStatus.cancelled);
        Navigator.pop(context, scanResult);
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text("Scanner")),
        body: Stack(
          children: [Center(child: CameraView(cameraEnhancer: _camera))],
        ),
      ),
    );
  }
}
