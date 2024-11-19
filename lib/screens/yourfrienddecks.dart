import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard/screens/optionplaydeckfriend.dart';
import 'package:flutter/material.dart';

class YourfriendDecks extends StatefulWidget {
  const YourfriendDecks({super.key});

  @override
  _YourfriendDecksState createState() => _YourfriendDecksState();
}

class _YourfriendDecksState extends State<YourfriendDecks> {
  bool isAddingDeck = false;
  String code = "";
  Map<String, dynamic>? deckInfo;

  Future<void> fetchSharedDeck() async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาใส่โค้ดแชร์ก่อน")),
      );
      return;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection('sharedDecks').doc(code);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final deckData = docSnap.data()!;
        setState(() {
          deckInfo = deckData;
        });
        // Show the second popup if deck is found
        showDeckInfoPopup();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deck ไม่พบ")),
        );
      }
    } catch (error) {
      print("Error fetching shared deck: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการดึงข้อมูล Deck")),
      );
    }
  }

  Future<void> handleAddDeck() async {
    if (deckInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่พบข้อมูล Deck")),
      );
      return;
    }

    final friendId = deckInfo!['friendId'];
    final deckId = deckInfo!['deckId'];
    final friendName = deckInfo!['friendName'];
    final description = deckInfo!['description'];
    final title = deckInfo!['title'];

    print("Adding deck: $deckInfo");

    try {
      if (friendId == FirebaseAuth.instance.currentUser?.uid) {
        Future.delayed(const Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ไม่สามารถเพิ่ม Deck ตัวเองได้")),
          );
          setState(() {
            isAddingDeck = false;
            code = "";
            deckInfo = null;
          });
          // Navigator.pop(context); // ปิด popup
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('Deck')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('deckFriend')
          .doc(deckId)
          .set({
        'friendId': friendId,
        'deckId': deckId,
        'friendName': friendName,
        'description': description,
        'title': title,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        isAddingDeck = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deck ได้ถูกเพิ่มเรียบร้อยแล้ว!")),
        );
        setState(() {
          isAddingDeck = false;
          code = "";
          deckInfo = null;
        });
        // Navigator.pop(context); // ปิด popup
      });
    } catch (error) {
      print("Error adding deck: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการเพิ่ม Deck")),
      );
    }
  }

  void showAddDeckPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Your Friend Deck"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Paste code to search"),
              TextField(
                decoration: const InputDecoration(hintText: "Paste code here"),
                onChanged: (value) {
                  setState(() {
                    code = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                fetchSharedDeck();
                Navigator.pop(context); // ปิด popup แรก
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }

  void showDeckInfoPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deckInfo!['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("รายละเอียด: ${deckInfo!['description']}"),
              Text("จำนวนการ์ด: ${deckInfo!['totalCard']}"),
              Text("สร้างโดย: ${deckInfo!['friendName']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                handleAddDeck();
                Navigator.pop(context); // ปิด popup แรก
              },
              child: Text(isAddingDeck ? "กำลังเพิ่ม..." : "เพิ่ม Deck"),
            ),
          ],
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 206, 140),
      body: Column(
        children: [
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: showAddDeckPopup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), // ระยะห่างภายในปุ่ม
              backgroundColor: Colors.white, // สีพื้นหลังของปุ่ม
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // ความโค้งมนของขอบ
                side: const BorderSide(
                    color: Color.fromARGB(255, 253, 254, 255),
                    width: 2), // สีและความกว้างของขอบ
              ),
              elevation: 4, // เงาของปุ่ม
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // ทำให้ขนาดปุ่มพอดีกับเนื้อหา
              children: [
                Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Add Your Friend Deck",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 92, 89, 89),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildDeckList(),
          ),
        ],
      ),
    );
  }

  Future<int> _getCardCount(String deckFriendId, String owner) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Deck')
          .doc(owner)
          .collection('title')
          .doc(deckFriendId)
          .collection('cards')
          .get();
      return snapshot.size;
    } catch (error) {
      print("Error getting card count: $error");
      return 0;
    }
  }

  Widget _buildDeckList() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to view your decks'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Deck')
          .doc(user.uid)
          .collection('deckFriend')
          .orderBy('createdAt')
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
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return GestureDetector(
                onTap: () async {
                  final cardCount =
                      await _getCardCount(deck.id, deck['friendId']);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OptionPlayDeckFriend(
                          deckId: deck.id,
                          title: deck['title'],
                          description: deck['description'],
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
                              return const Text("Error",
                                  style: TextStyle(color: Colors.red));
                            } else {
                              final cardCount = snapshot.data ?? 0;
                              return Text(
                                "$cardCount card${cardCount != 1 ? 's' : ''}",
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
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
