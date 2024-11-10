import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard/screens/mydecks.dart';
import 'package:flashcard/auth/auth_service.dart'; // import AuthService
import 'package:flashcard/auth/login_screen.dart'; // import LoginScreen
import 'package:flashcard/screens/yourfrienddecks.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Decks());
}

class Decks extends StatelessWidget {
  const Decks({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: DefaultTabController(
        length: 2, // จำนวน tab
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard'),
                _buildUserName(), // เพิ่มการแสดงชื่อผู้ใช้
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout), // ใช้ไอคอน logout
                onPressed: () => _logout(context), // เรียกฟังก์ชัน logout เมื่อกดปุ่ม
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: "My Decks"),
                Tab(text: "Your Friend Decks"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MyDecks(),
              YourfriendDecks()
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 227, 206, 140),
        ),
      ),
    );
  }

  // ฟังก์ชันดึงชื่อผู้ใช้จาก Firestore
  Future<String?> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
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

  // ฟังก์ชันแสดงชื่อผู้ใช้ใน AppBar
  Widget _buildUserName() {
    return FutureBuilder<String?>(
      future: fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // หากข้อมูลยังโหลดไม่เสร็จ จะแสดงวงกลมหมุน
        } else if (snapshot.hasError) {
          return const Text(
            'Error loading user data',
            style: TextStyle(fontSize: 12),
          );
        } else if (!snapshot.hasData) {
          return const Text(
            'No user data found',
            style: TextStyle(fontSize: 12),
          );
        } else {
          final userName = snapshot.data;
          return Text(
            'Hello, $userName!', // แสดงชื่อผู้ใช้ที่ดึงมาได้
            style: const TextStyle(fontSize: 16),
          );
        }
      },
    );
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout(BuildContext context) async {
    final AuthService _authService = AuthService(); // สร้าง instance ของ AuthService
    await _authService.signout(); // ออกจากระบบ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // ไปที่หน้า LoginScreen
      (Route<dynamic> route) => false, // ลบเส้นทางทั้งหมดก่อนหน้านี้
    );
  }
}
