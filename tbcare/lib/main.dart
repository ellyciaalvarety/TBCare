import 'package:flutter/material.dart';
import 'package:tbcare/features/auth/screens/register_screen.dart'; // 1. Import file login kamu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Care',
      theme: ThemeData(
        useMaterial3: true,
        // Masukkan TBCareTheme.light kamu di sini jika sudah dipisah filenya
      ),
      home: const RegisterScreen(), // 2. Panggil class halaman login di sini
    );
  }
}