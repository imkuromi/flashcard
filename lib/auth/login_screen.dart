// lib/auth/login_screen.dart
import 'dart:developer';

import 'package:flashcard/auth/auth_service.dart';
import 'package:flashcard/auth/signup_screen.dart';
import 'package:flashcard/screens/decks.dart';
import 'package:flashcard/widgets/button.dart';
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
            const Text("Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
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
              width: 250,
              child: CustomButton(
                label: "Login",
                onPressed: _login,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 250,
              child: CustomButton(
                label: "Sign in with Google",
                onPressed: () async {
                  final userCredential = await _auth.loginWithGoogle();
                  if (userCredential != null) {
                    goToDecks(context); // Navigate to DeckListScreen
                  }
                },
              ),
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToSignup(context),
                child: const Text("Signup", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  // ฟังก์ชันเพื่อไปยังหน้า DeckListScreen
  goToDecks(BuildContext context) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Decks()),
      );

  _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
        _email.text, _password.text);

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
