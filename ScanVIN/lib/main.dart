import 'package:flutter/material.dart';

import 'scan_page.dart';
import 'vin_scan_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan VIN',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: 'Scan VIN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _scanResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_scanResult, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20), //add some space
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerPage())) as VINScanResult;

                setState(() {
                  if (result.resultStatus == EnumResultStatus.finished) {
                    _scanResult = result.data!
                        .toMap()
                        .entries
                        .map((entry) {
                          return "${entry.key}: ${entry.value}";
                        })
                        .join("\n");
                  } else if (result.resultStatus == EnumResultStatus.cancelled) {
                    _scanResult = 'Scan cancelled';
                  } else if (result.resultStatus == EnumResultStatus.error) {
                    _scanResult = 'Error message: ${result.errorString}';
                  }
                });
              },
              style: TextButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text('Open VIN Scanner'),
            ),
            const SizedBox(height: 50),  //add some space
          ],
        ),
      ),
    );
  }
}
