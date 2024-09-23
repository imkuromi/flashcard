import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard/screens/cards.dart';
import 'package:flutter/material.dart';

class MyDecks extends StatelessWidget {
  MyDecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // เพิ่มส่วนการแสดง Decks
          Expanded(
            child: _buildDeckList(),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันดึงจำนวนการ์ดใน Deck
  Future<int> _getCardCount(String deckId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0; // ถ้าไม่มีผู้ใช้ที่ล็อกอินอยู่
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Deck') // Collection Deck
          .doc(user.uid) // Document ตาม uid ของผู้ใช้
          .collection('title') // Collection title ภายใน Document
          .doc(deckId) // เข้าถึง Deck ที่ต้องการ
          .collection('cards') // เข้าถึง Collection การ์ดภายใน Deck นั้น ๆ
          .get();
      return snapshot.size; // คืนค่าจำนวนการ์ดใน Deck นั้น ๆ
    } catch (error) {
      print("Error getting card count: $error");
      return 0;
    }
  }

  // ฟังก์ชันแสดงรายการ Deck ในรูปแบบ GridView
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

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // จำนวนคอลัมน์ของ Grid
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];

              return GestureDetector(
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
                child: Card(
                  color: const Color.fromARGB(255, 132, 203, 232),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          deck['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ส่วนที่เพิ่มสำหรับการแสดงจำนวนการ์ด
                        FutureBuilder<int>(
                          future: _getCardCount(deck.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text(
                                "Error",
                                style: TextStyle(color: Colors.red),
                              );
                            } else {
                              final cardCount = snapshot.data ?? 0;
                              return Text(
                                "$cardCount card${cardCount != 1 ? 's' : ''}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
