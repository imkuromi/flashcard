// lib/screens/cards.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CardsScreen extends StatelessWidget {
  final String deckId;
  final String title;

  const CardsScreen({super.key, required this.deckId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // ส่วนของ ListView สำหรับแสดงข้อมูลการ์ด
          Expanded(child: _buildCardList()), // ใช้ Expanded เพื่อให้ ListView ขยายเต็มพื้นที่
        ],
      ),
    );
  }

  Widget _buildCardList() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(
        child: Text("Please login to view your decks"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Deck')
          .doc(user.uid)
          .collection('title')
          .doc(deckId)
          .collection('cards')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final cards = snapshot.data!.docs;

        // เช็คว่ามีการ์ดหรือไม่
        if (cards.isEmpty) {
          return const Center(child: Text("No cards available in this deck"));
        }

        return ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];

            return ListTile(
              title: Text(card['questionFront']), // แสดงคำถามด้านหน้า
              subtitle: Text(card['answerBack']), // แสดงคำตอบด้านหลัง (ถ้ามี)
              onTap: () {
                // ใส่การทำงานเมื่อคลิกแต่ละการ์ด (เช่น การแสดงผลเพิ่มเติม)
              },
            );
          },
        );
      },
    );
  }
}
