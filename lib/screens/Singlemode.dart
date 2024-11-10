import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers package
import 'dart:math'; // Import this to use Random
import 'package:flashcard/screens/decks.dart';

class Singlemode extends StatelessWidget {
  final String deckId;
  final String startSide; // Variable to receive startSide
  final String title;
  final int cardCount;
  final int
      enterCard; // Variable to receive the number of cards from OptionPlay
  final String friendId;

  const Singlemode({
    super.key,
    required this.deckId,
    required this.startSide,
    required this.title,
    required this.enterCard,
    required this.cardCount,
    required this.friendId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Flip',
      home: CardFlipScreen(
        deckId: deckId,
        startSide: startSide,
        title: title,
        friendId: friendId,
        cardCount: cardCount,
        enterCard: enterCard,
      ), // Pass values to CardFlipScreen
    );
  }
}

class CardFlipScreen extends StatefulWidget {
  final String deckId;
  final String startSide;
  final String title;
  final int cardCount;
  final int enterCard;
  final String friendId;

  const CardFlipScreen({
    Key? key,
    required this.deckId,
    required this.startSide,
    required this.title,
    required this.cardCount,
    required this.enterCard,
    required this.friendId,
  }) : super(key: key);

  @override
  _CardFlipScreenState createState() => _CardFlipScreenState();
}

class _CardFlipScreenState extends State<CardFlipScreen> {
  List<CardData> cards = [];
  int currentIndex = 0;
  bool isLoading = true;

  final AudioPlayer audioPlayer = AudioPlayer(); // Create AudioPlayer

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    final user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch data from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Deck')
          .doc(widget.friendId.isEmpty? user.uid : widget.friendId)
          .collection('title')
          .doc(widget.deckId)
          .collection('cards')
          .orderBy('timestamp')
          .limit(widget.cardCount) // Limit the number of cards fetched
          .get();

      // Shuffle the cards after fetching them
      setState(() {
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
            isFlipped: widget.startSide !=
                'front', // Set flipped state based on startSide
          );
        }).toList();

        // Shuffle the list of cards
        cards.shuffle(Random()); // Shuffle the cards randomly
        isLoading = false;
      });
    }
  }

  void _nextCard() {
    setState(() {
      if (currentIndex < widget.enterCard - 1) {
        currentIndex++;
      } else {
        _showCompletionDialog(); // Show popup when all cards are played
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // เพิ่มความโค้งมนให้กับขอบ
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green, // เพิ่มไอคอนที่ให้ความรู้สึกสำเร็จ
              ),
              SizedBox(width: 10), // เว้นช่องว่างระหว่างไอคอนกับข้อความ
              Text(
                'Completed!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'You have played all the selected cards!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey, // เปลี่ยนสีตัวอักษรให้นุ่มนวลขึ้น
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // ปรับสีปุ่มให้นำสมัย
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // ปุ่มโค้งมน
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Decks(),
                  ),
                );
              },
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(
                  color: Colors.white, // ปรับสีตัวอักษรให้ดูคมชัดขึ้น
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> playAudio(String url) async {
    try {
      await audioPlayer
          .play(UrlSource(url)); // Use UrlSource for playing audio from URL
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 226, 136),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 226, 136),
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align title to the left
          children: [
            Text(
              '${widget.title}  ', // Display number of cards in title
            ),
            const SizedBox(
                height: 4), // Add some space between title and subtitle
            Text(
              '${currentIndex + 1} out of ${widget.enterCard} cards', // Add your custom message here
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54), // Style for the subtitle
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Decks(),
              ),
            );
          },
        ),
      ),
      body: cards.isEmpty
          ? const Center(
              child: Text('No cards available'),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  cards[currentIndex].isFlipped =
                      !cards[currentIndex].isFlipped;
                });
              },
              onHorizontalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx > 0) {
                  _previousCard();
                } else {
                  _nextCard();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 40), // Adjust this value to move the card up
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: SizedBox(
                            width: 350, // Set card width
                            height: 600, // Set card height
                            child: cards[currentIndex].isFlipped
                                ? Card(
                                    key: ValueKey('back$currentIndex'),
                                    color: Colors.teal,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          cards[currentIndex].layoutBack ??
                                              'No Layout',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          cards[currentIndex].questionBack ??
                                              'No Question',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 10),
                                        if (cards[currentIndex].imageUrlBack !=
                                            null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Image.network(
                                                cards[currentIndex]
                                                    .imageUrlBack!),
                                          ),
                                      ],
                                    ),
                                  )
                                : Card(
                                    key: ValueKey('front$currentIndex'),
                                    color:
                                        const Color.fromARGB(255, 89, 188, 221),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          cards[currentIndex].layoutFront ??
                                              'No Layout',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          cards[currentIndex].questionFront ??
                                              'No Question',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 20),
                                        if (cards[currentIndex].imageUrlFront !=
                                            null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Image.network(
                                                cards[currentIndex]
                                                    .imageUrlFront!),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if ((cards[currentIndex].isFlipped &&
                            cards[currentIndex].audioUrlBack != null) ||
                        (!cards[currentIndex].isFlipped &&
                            cards[currentIndex].audioUrlFront != null))
                      Positioned(
                        bottom:
                            0, // Increase this value to move the icon further away from the card
                        child: IconButton(
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            size: 60,
                            color: Color.fromARGB(255, 236, 88, 68),
                          ),
                          onPressed: () {
                            final audioUrl = cards[currentIndex].isFlipped
                                ? cards[currentIndex].audioUrlBack
                                : cards[currentIndex].audioUrlFront;
                            if (audioUrl != null) {
                              playAudio(audioUrl);
                            }
                          },
                        ),
                      ),
                    Positioned(
                      left: 25,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_circle_left_sharp,
                          size: 50,
                          color: Color.fromARGB(255, 126, 124, 122),
                        ),
                        onPressed: _previousCard,
                      ),
                    ),
                    Positioned(
                      right: 25,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_circle_right_sharp,
                          size: 50,
                          color: Color.fromARGB(255, 126, 124, 122),
                        ),
                        onPressed: _nextCard,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CardData {
  final String? layoutFront;
  final String? questionFront;
  final String? imageUrlFront;
  final String? audioUrlFront;
  final String? layoutBack;
  final String? questionBack;
  final String? imageUrlBack;
  final String? audioUrlBack;
  bool isFlipped;

  CardData({
    required this.layoutFront,
    required this.questionFront,
    required this.imageUrlFront,
    required this.audioUrlFront,
    required this.layoutBack,
    required this.questionBack,
    required this.imageUrlBack,
    required this.audioUrlBack,
    required this.isFlipped,
  });
}
