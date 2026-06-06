import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_internals.dart'
    show initDatabaseFactory;

void main() {
  if (kIsWeb) {
    runApp(const UnsupportedPlatformApp());
    return;
  }

  // Initialize sqflite_common_ffi only on desktop platforms.
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    initDatabaseFactory();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TB Care',
      debugShowCheckedModeBanner: false,
      theme: TBCareTheme.light,
      routerConfig: router,
    );
  }
}

class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Care - Unsupported Platform',
      debugShowCheckedModeBanner: false,
      theme: TBCareTheme.light,
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Platform web tidak didukung oleh aplikasi ini karena penyimpanan lokal menggunakan SQLite.\n\nSilakan jalankan aplikasi di Android, iOS, atau desktop (Windows/macOS/Linux) untuk menggunakan fitur pendaftaran dan login.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}
