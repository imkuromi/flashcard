// lib/auth/login_screen.dart
import 'dart:developer';

import 'package:flashcard/auth/auth_service.dart';
import 'package:flashcard/screens/decks.dart';
import 'package:flashcard/widgets/textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            Image.asset('assets/images/Flashcard.png'),
            const Text("Sign in",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                )),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              controller: _password,
            ),
            const SizedBox(height: 30),
            Container(
              width: 280,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลัง
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // กำหนดมุมโค้ง
                  ),
                ),
                onPressed: _login,
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15,),
            Container(
              width: 280,
              height: 45,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลัง
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // กำหนดมุมโค้ง
                    ),
                  ),
                  onPressed: () async {
                    final userCredential = await _auth.loginWithGoogle();
                    if (userCredential != null) {
                      goToDecks(context); // Navigate to DeckListScreen
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                      Container(
                        width: 20, // กำหนดความกว้างของรูปภาพ
                        child: Image.asset(
                          'assets/images/google.png',
                          fit: BoxFit.contain, // ปรับขนาดภาพให้เหมาะสม
                        ),
                      ),
                      const SizedBox(width: 15,),
                      const Text(
                        "Sign in with Google",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    ],
                  )),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันเพื่อไปยังหน้า DeckListScreen
  goToDecks(BuildContext context) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Decks()),
      );

  _login() async {
    final user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("User Logged In");
      goToDecks(context); // Navigate to DeckListScreen
    } else {
      // แสดงข้อความแจ้งเตือนเมื่อเข้าสู่ระบบไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login failed. Please check your credentials."),
        ),
      );
    }
  }
}
