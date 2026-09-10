import 'package:flutter/material.dart';

import 'camera_screen.dart';
import '../scan_result_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _itemIdController = TextEditingController();

  void _handleScanPressed() {
    setScanResultDelegate((String text) {
      if (!mounted) {
        return;
      }
      setState(() {
        _itemIdController.text = text;
      });
    });

    Navigator.of(context).pushNamed(
      CameraScreen.routeName,
      arguments: const CameraScreenArgs(mode: CameraMode.scan),
    );
  }

  void _startSearch() {
    final String itemId = _itemIdController.text.trim();
    if (itemId.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Hint'),
            content: Text('Please enter or scan an Item ID first.'),
          );
        },
      );
      return;
    }

    Navigator.of(context).pushNamed(
      CameraScreen.routeName,
      arguments: CameraScreenArgs(mode: CameraMode.search, targetText: itemId),
    );
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: const Color(0xFF5A5A5A),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Center(
                  child: Text(
                    'Locate an Item with Barcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "1.Enter or Scan the Item ID that you're searching for:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDDDDDD),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _itemIdController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          hintText: 'Enter Item ID',
                          hintStyle: const TextStyle(color: Color(0xFF999999)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _handleScanPressed,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          '📷',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '2.Start searching for the item',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDDDDDD),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Searching',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
