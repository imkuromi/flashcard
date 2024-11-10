// lib/services/api_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:math';

import 'package:flashcard/services/card_data.dart';

class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CardData>> fetchCards(String deckId, int cardCount) async {
    final user = _auth.currentUser;
    List<CardData> cards = [];

    if (user != null) {
      final querySnapshot = await _firestore
          .collection('Deck')
          .doc(user.uid)
          .collection('title')
          .doc(deckId)
          .collection('cards')
          .orderBy('timestamp')
          .limit(cardCount)
          .get();

      cards = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CardData(
          layoutFront: data['layoutFront'],
          questionFront: data['questionFront'],
          imageUrlFront: data['imageUrlFront'],
          audioUrlFront: data['audioUrlFront'],
          layoutBack: data['layoutBack'],
          questionBack: data['questionBack'],
          imageUrlBack: data['imageUrlBack'],
          audioUrlBack: data['audioUrlBack'],
          isFlipped: false, // ค่าเริ่มต้นคือ false
        );
      }).toList();

      // สับการ์ด
      cards.shuffle(Random());
    }
    
    return cards;
  }
}
