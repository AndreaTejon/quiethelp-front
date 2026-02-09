import 'package:flutter/material.dart';
import 'package:quiethelp_front/loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF2CB9B2);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuietHelp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: teal),
        useMaterial3: true,
      ),
      home: const LoadingPage(),
    );
  }
}


