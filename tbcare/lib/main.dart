import 'package:flutter/material.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TB Care',
      debugShowCheckedModeBanner: false,
      theme: TBCareTheme.light, // sesuaikan dengan nama theme kamu
      routerConfig: router, // ← GoRouter dari routes.dart
    );
  }
}
