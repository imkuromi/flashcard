// lib/main.dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashcard/auth/login_screen.dart';
import 'package:flashcard/screens/Singlemode.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyApWx2LK3KKhL6asYRKBPj_M5s2UrlwPB0",
            authDomain: "flash-card-db.firebaseapp.com",
            projectId: "flash-card-db",
            storageBucket: "flash-card-db.appspot.com",
            messagingSenderId: "368264992287",
            appId: "1:368264992287:web:b5576252ad2dd278ab272a",
            measurementId: "G-C1SCYV3KJ6"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Singlemode(),
      // home: LoginScreen(), // ใช้ LoginScreen เป็นหน้าเริ่มต้น
    );
  }
}
