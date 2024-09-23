import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard/screens/cards.dart';
import 'package:flutter/material.dart';
import 'package:flashcard/auth/auth_service.dart';
import 'package:flashcard/auth/login_screen.dart';

class DeckListScreen extends StatelessWidget {
  final AuthService _authService =
      AuthService(); // สร้าง instance ของ AuthService

  DeckListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // ใช้ไอคอน logout
            onPressed: () =>
                _logout(context), // เรียกฟังก์ชัน logout เมื่อกดปุ่ม
          ),
        ],
      ),
      body: Column(
        children: [
          // ใช้ FutureBuilder เพื่อดึงชื่อผู้ใช้
          _buildUserName(),
          // เพิ่มส่วนการแสดง Decks
          Expanded(
            child: _buildDeckList(),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันดึงชื่อผู้ใช้จาก Firestore
  Future<String?> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      try {
        final userSnap = await userRef.get();
        if (userSnap.exists) {
          return userSnap.data()?['name']; // ดึงชื่อจาก document 'name'
        } else {
          print("No such document!");
          return null;
        }
      } catch (error) {
        print("Error getting document: $error");
        return null;
      }
    }
    return null;
  }

  // ฟังก์ชันแสดงชื่อผู้ใช้
  Widget _buildUserName() {
    return FutureBuilder<String?>(
      future: fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading user data'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No user data found'));
        } else {
          final userName = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hello, $userName!', // แสดงชื่อผู้ใช้ที่ดึงมาได้
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }

  // ฟังก์ชันแสดงรายการ Deck
  Widget _buildDeckList() {
    final user = FirebaseAuth.instance.currentUser; // user ที่ login เข้ามา

    if (user == null) {
      return const Center(
          child: Text(
              'Please login to view your decks')); // กรณีไม่มีผู้ใช้ล็อกอินอยู่
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Deck') // เข้าถึง Collection Deck
          .doc(user.uid) // เข้าถึง Document ตาม uid ของผู้ใช้
          .collection('title') // เข้าถึง Collection title ภายใน Document
          .orderBy('timestamp') // เรียงตาม timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final decks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];

            return ListTile(
              title: Text(deck['title']),
              subtitle: Text(deck['description']?? ""),
              onTap: () {
                // เมื่อกดที่รายการ deck จะนำไปยังหน้า Cards พร้อมส่ง deckId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                   builder: (context) => CardsScreen(
                      deckId: deck.id, // ID ของ deck
                      title: deck['title'], // ชื่อของ deck
                    ),
                  ),
                );
              },
              // เพิ่มส่วนเพิ่มเติมอื่น ๆ ได้ตามต้องการ เช่นจำนวนการ์ดใน Deck
            );
          },
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.signout(); // ออกจากระบบ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // ลบเส้นทางทั้งหมดก่อนหน้านี้
    );
  }
}
