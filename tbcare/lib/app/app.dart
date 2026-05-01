import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';

class TBCareApp extends StatelessWidget {
  const TBCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TBCare',
      theme: TBCareTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}