// lib/screens/home_screen.dart
import 'package:flashcard/auth/auth_service.dart';
import 'package:flashcard/auth/login_screen.dart';
import 'package:flashcard/screens/decks.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome $email",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // กำหนดสีพื้นหลัง
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // กำหนดมุมโค้ง
                  ),
                ),
                onPressed: () async {
                  goToDecks(context);
                },
                child: const Text(
                  "Go to Decks",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // กำหนดสีพื้นหลัง
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // กำหนดมุมโค้ง
                  ),
                ),
                onPressed: () async {
                  await auth.signout();
                  goToLogin(context);
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToDecks(BuildContext context) => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const Decks()));
}
