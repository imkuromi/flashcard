import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flashcard/screens/cards.dart';
import 'package:flashcard/screens/optionplaydeckfriend.dart';
import 'package:flutter/material.dart';

class YourfriendDecks extends StatelessWidget {
  YourfriendDecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 227, 206, 140), // เพิ่มสี background ที่นี่
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
  Future<int> _getCardCount(String deckFriendId, String owner) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0; // ถ้าไม่มีผู้ใช้ที่ล็อกอินอยู่
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Deck') // Collection Deck
          .doc(owner) // Document ตาม uid ของผู้ใช้
          .collection('title') // Collection title ภายใน Document
          .doc(deckFriendId) // เข้าถึง Deck ที่ต้องการ
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
          .collection('deckFriend') // เข้าถึง Collection title ภายใน Document
          .orderBy('createdAt') // เรียงตาม timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final decks = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // จำนวนคอลัมน์ของ Grid
              childAspectRatio: 3 / 2,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return GestureDetector(
                onTap: () async {
                  final cardCount = await _getCardCount(deck.id, deck['friendId']);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OptionPlayDeckFriend(
                          deckId: deck.id,
                          title: deck['title'],
                          friendId: deck['friendId'],
                          cardCount: cardCount,
                          enterCard: cardCount,
                        ),
                      ),
                    );
                  }
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
                        FutureBuilder<int>(
                          future: _getCardCount(deck.id, deck['friendId']),
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
