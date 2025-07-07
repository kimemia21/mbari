import 'package:flutter/material.dart';
import 'package:mbari/auth/Login.dart';
import 'package:mbari/auth/Signup.dart';
import 'package:mbari/routing/Navigator.dart' show ExampleUsage;
import 'package:mbari/core/theme/AppTheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
     theme: AppTheme.darkTheme,
      home: Login()
    //  ExampleUsage()
    );
  }
}

