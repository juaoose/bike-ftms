import 'package:bike_ftms/screens/file_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Indoor Cyclist'),
        ),
        body: const Center(
          child: FileSelectionScreen(),
        ),
      ),
    );
  }
}
