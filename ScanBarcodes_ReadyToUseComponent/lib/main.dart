import 'package:dynamsoft_barcode_reader_bundle_flutter/dynamsoft_barcode_reader_bundle_flutter.dart';
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
      title: 'Scan Barcodes RTU',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: 'Scan Barcodes RTU'),
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
  String _displayString = "";

  void _launchBarcodeScanner(EnumScanningMode scanningMode) async {
    var config = BarcodeScannerConfig(license: "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", scanningMode: scanningMode);
    BarcodeScanResult barcodeScanResult = await BarcodeScanner.launch(config);

    setState(() {
      if (barcodeScanResult.status == EnumResultStatus.canceled) {
        _displayString = "Scan canceled";
      } else if (barcodeScanResult.status == EnumResultStatus.exception) {
        _displayString = "ErrorCode: ${barcodeScanResult.errorCode}\n\nErrorString: ${barcodeScanResult.errorMessage}";
      } else {
        //EnumResultStatus.finished
        if (scanningMode == EnumScanningMode.single) {
          var barcode = barcodeScanResult.barcodes![0];
          _displayString = "Format: ${barcode.formatString}\nText: ${barcode.text}";
        } else {
          // EnumScanningMode.multiple
          _displayString =
              "Barcodes count: ${barcodeScanResult.barcodes!.length}\n\n"
              "${barcodeScanResult.barcodes!.map((barcode) {
                return "Format: ${barcode.formatString}\nText: ${barcode.text}";
              }).join("\n\n")}";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: ()=>_launchBarcodeScanner(EnumScanningMode.single),
                style: TextButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text("Scan Single Barcode"),
              ),
              SizedBox(height: 20), // Add a spacing of 20
              TextButton(
                onPressed: ()=>_launchBarcodeScanner(EnumScanningMode.multiple),
                style: TextButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text("Scan multiple Barcodes"),
              ),
              SizedBox(height: 20), // Add a spacing of 20
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(_displayString, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
