import 'package:flutter/material.dart';
import 'package:mbari/auth/Login.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/theme/AppTheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mbari/core/utils/sharedPrefs.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   
  userPrefs = await UserPreferences.getInstance();
   // initialize global instance
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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


