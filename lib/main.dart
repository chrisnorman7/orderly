import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The top-level app class.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({super.key});

  /// Build the widget.
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Orderly',
    theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    home: const Placeholder(),
  );
}
