import 'package:flutter/material.dart';
import 'package:scenario_optimized_scanning/scanner_screen.dart';

void main() {
  runApp(const MainApp());
}

class ScannerOption {
  const ScannerOption({
    required this.label,
    required this.imageAsset,
    required this.templateFile,
  });

  final String label;
  final String imageAsset;
  final String templateFile;
}

const List<ScannerOption> _barcodeFormats = <ScannerOption>[
  ScannerOption(
    label: 'Any Codes',
    imageAsset: 'assets/common_2d_1d@3x.png',
    templateFile: '',
  ),
  ScannerOption(
    label: '1D Retail',
    imageAsset: 'assets/1d_retail@3x.png',
    templateFile: 'ReadOneDRetail.json',
  ),
  ScannerOption(
    label: '1D Industrial',
    imageAsset: 'assets/1d_industrial@3x.png',
    templateFile: 'ReadOneDIndustrial.json',
  ),
  ScannerOption(
    label: 'QR Code',
    imageAsset: 'assets/qr_code@3x.png',
    templateFile: 'ReadQR.json',
  ),
  ScannerOption(
    label: 'Data Matrix',
    imageAsset: 'assets/data_matrix@3x.png',
    templateFile: 'ReadDataMatrix.json',
  ),
  ScannerOption(
    label: 'Common 2D\ncodes',
    imageAsset: 'assets/common_2d@3x.png',
    templateFile: 'ReadCommon2D.json',
  ),
  ScannerOption(
    label: 'Aztec Code',
    imageAsset: 'assets/aztec_code@3x.png',
    templateFile: 'ReadAztec.json',
  ),
  ScannerOption(
    label: 'Dot Code',
    imageAsset: 'assets/dot_code@3x.png',
    templateFile: 'ReadDotCode.json',
  ),
  ScannerOption(
    label: 'Direct Part\nMarking(DPM)',
    imageAsset: 'assets/dpm@3x.png',
    templateFile: 'ReadDPM.json',
  ),
  ScannerOption(
    label: 'PDF417',
    imageAsset: 'assets/pdf417@3x.png',
    templateFile: 'ReadPDF417.json',
  ),
];

const List<ScannerOption> _scenarios = <ScannerOption>[
  ScannerOption(
    label: 'High-Density\nCode',
    imageAsset: 'assets/high_density@3x.png',
    templateFile: 'ReadDenseBarcodes.json',
  ),
];

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario Optimized Scanning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF151517),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF151517)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/dynamsoft-logo@3x.png',
                width: 200,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Select Scanner by Barcode Format'),
              const SizedBox(height: 16),
              _OptionGrid(items: _barcodeFormats),
              const SizedBox(height: 8),
              const _SectionTitle('Select Scanner by Your Scenario'),
              const SizedBox(height: 16),
              _OptionGrid(items: _scenarios),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF4ECDC4),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({required this.items});

  final List<ScannerOption> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ScannerOption item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ScannerScreen(templateFile: item.templateFile),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.black : const Color(0xFF1D1D1D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3D3D3D)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

