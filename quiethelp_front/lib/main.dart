import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://losnmfekwxbvcaldnzij.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxvc25tZmVrd3hidmNhbGRuemlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5NjE0NjgsImV4cCI6MjA4NjUzNzQ2OH0.0pDtIfK1USpt37aY-9h6zgkmSkR7OznFQ3baHImZtvE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuietHelp',
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(),
    );
  }
}