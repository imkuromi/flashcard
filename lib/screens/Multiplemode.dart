import 'package:flashcard/screens/optionplaydeckfriend.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flashcard/screens/decks.dart';
import 'package:flashcard/screens/render_card_content.dart';

class MultipleMode extends StatelessWidget {
  final String deckId;
  final String startSide;
  final String title;
  final int cardCount;
  final int enterCard;
  final String friendId;

  const MultipleMode({
    super.key,
    required this.deckId,
    required this.startSide,
    required this.title,
    required this.cardCount,
    required this.enterCard,
    required this.friendId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiple Mode',
      home: MultipleChoiceScreen(
        deckId: deckId,
        startSide: startSide,
        title: title,
        friendId: friendId,
        cardCount: cardCount,
        enterCard: enterCard,
      ),
    );
  }
}

class MultipleChoiceScreen extends StatefulWidget {
  final String deckId;
  final String startSide;
  final String title;
  final int cardCount;
  final int enterCard;
  final String friendId;

  const MultipleChoiceScreen({
    super.key,
    required this.deckId,
    required this.startSide,
    required this.title,
    required this.cardCount,
    required this.enterCard,
    required this.friendId,
  });

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  List<CardData> cards = [];
  int currentIndex = 0;
  int score = 0; // Variable to keep track of the score
  late DateTime startTime;
  List<List<OptionData>> allOptions = [];

  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchCards();
    startTime = DateTime.now();
    allOptions = List.generate(widget.enterCard, (_) => []);
  }

  Future<void> fetchCards() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Deck')
            .doc(widget.friendId.isEmpty ? user.uid : widget.friendId)
            .collection('title')
            .doc(widget.deckId)
            .collection('cards')
            // .orderBy('timestamp')
            .limit(widget.cardCount)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            cards = querySnapshot.docs.map((doc) {
              final data = doc.data();
              return CardData(
                layoutFront: data['layoutFront'],
                questionFront: data['questionFront'],
                correctAnswer: widget.startSide == 'front'
                    ? data['questionBack'] ??
                        data['imageUrlBack'] ??
                        data['audioUrlBack']
                    : data['questionFront'] ??
                        data['imageUrlFront'] ??
                        data['audioUrlFront'],
                imageUrlFront: data['imageUrlFront'],
                audioUrlFront: data['audioUrlFront'],
                layoutBack: data['layoutBack'],
                questionBack: data['questionBack'],
                imageUrlBack: data['imageUrlBack'],
                audioUrlBack: data['audioUrlBack'],
                isFlipped: widget.startSide != 'front',
              );
            }).toList();

            cards.shuffle(Random());
          });
        } else {
          print('No cards found in the deck.');
        }
      } catch (e) {
        print('Error fetching cards: $e');
      }
    }
  }

  Future<void> playAudio(String url) async {
    try {
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _nextCard() {
    setState(() {
      if (currentIndex < widget.enterCard - 1) {
        currentIndex++;
      } else {
        _showCompletionDialog();
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

  // void _previousCard() {
  //   setState(() {
  //     if (currentIndex > 0) {
  //       currentIndex--;
  //     }
  //   });
  // }

  void _showCompletionDialog() {
    int elapsedTime = (DateTime.now().difference(startTime).inSeconds);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 10),
              Text('Completed!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'You answered $score out of ${widget.enterCard} questions correctly!',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 131, 190, 239),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Decks()),
                );
              },
              child: const Text('Back to Dashboard',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    saveGameResult(score, widget.enterCard, elapsedTime);
  }

  Future<void> saveGameResult(int score, int enterCard, int elapsedTime) async {
    // ตรวจสอบผู้ใช้ที่เข้าสู่ระบบ
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in');
      return; // ออกจากฟังก์ชันถ้าผู้ใช้ไม่ได้เข้าสู่ระบบ
    }

    // อ้างอิงไปยัง collection 'gameResults'
    final gameResultsRef = FirebaseFirestore.instance
        .collection('Deck') // ชื่อ collection หลัก
        .doc(user.uid) // เอกสารของผู้ใช้
        .collection(widget.friendId.isEmpty
            ? 'title'
            : 'deckFriend') // collection ย่อยสำหรับชื่อเด็ค
        .doc(widget.deckId) // เอกสารสำหรับ deck ที่เฉพาะเจาะจง
        .collection('gameResults'); // collection สำหรับบันทึกผลเกม

    try {
      // เพิ่มข้อมูลผลเกมลงใน Firestore
      await gameResultsRef.add({
        'cardCount': enterCard, // จำนวนการ์ดที่ผู้ใช้ได้เข้า
        'score': score, // คะแนนที่ได้รับ
        'time': elapsedTime, // เวลาใน milliseconds
        'timestamp': FieldValue.serverTimestamp(), // ใช้ timestamp จาก server
      });
      print('Game result saved successfully.');
    } catch (e) {
      // แสดงข้อผิดพลาดถ้ามี
      print('Error saving game result: $e');
    }
  }

  List<OptionData> _generateOptions() {
    if (cards.isEmpty || currentIndex >= cards.length) {
      return []; // ถ้าการ์ดว่างหรือดัชนีเกินขอบเขต ให้คืนค่าตัวเลือกว่าง
    }

    if (allOptions[currentIndex].isNotEmpty) {
      return allOptions[currentIndex];
    }

    List<OptionData> options = [];
    Set<String> optionSet = {};

    String correctAnswer = cards[currentIndex].correctAnswer;

    options.add(OptionData(
      layout: widget.startSide == 'front'
          ? cards[currentIndex].layoutBack!
          : cards[currentIndex].layoutFront!,
      question: correctAnswer,
      imageUrl: widget.startSide == 'front'
          ? cards[currentIndex].imageUrlBack
          : cards[currentIndex].imageUrlFront,
      audioUrl: widget.startSide == 'front'
          ? cards[currentIndex].audioUrlBack
          : cards[currentIndex].audioUrlFront,
    ));

    optionSet.add(correctAnswer);

    while (options.length < 4 && cards.isNotEmpty) {
      int randomIndex = Random().nextInt(cards.length);

      if (randomIndex != currentIndex) {
        String incorrectAnswer = widget.startSide == 'front'
            ? cards[randomIndex].questionBack!
            : cards[randomIndex].questionFront!;

        if (!optionSet.contains(incorrectAnswer)) {
          options.add(OptionData(
            layout: widget.startSide == 'front'
                ? cards[randomIndex].layoutBack!
                : cards[randomIndex].layoutFront!,
            question: incorrectAnswer,
            imageUrl: widget.startSide == 'front'
                ? cards[randomIndex].imageUrlBack
                : cards[randomIndex].imageUrlFront,
            audioUrl: widget.startSide == 'front'
                ? cards[randomIndex].audioUrlBack
                : cards[randomIndex].audioUrlFront,
          ));
          optionSet.add(incorrectAnswer);
        }
      }
    }

    options.shuffle(Random());
    allOptions[currentIndex] = options;
    return options;
  }

  void _handleAnswerSelection(String selectedAnswer) {
    if (!cards[currentIndex].isAnswered) {
      // ตรวจสอบว่าตอบแล้วหรือยัง
      setState(() {
        cards[currentIndex].selectedOption =
            selectedAnswer; // เก็บคำตอบที่เลือก
        cards[currentIndex].isAnswered = true; // เปลี่ยนสถานะเป็นตอบแล้ว
        if (selectedAnswer == cards[currentIndex].correctAnswer) {
          score++; // เพิ่มคะแนนถ้าตอบถูก
        }
      });
    }
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบเงื่อนไขการ์ดก่อน หากมีน้อยกว่า 5
    List<OptionData> options = _generateOptions();
    debugPrint(options.toString());

    debugPrint('Number of cards: ${cards.length}');
    // if (cards.length < 4) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       leading: IconButton(
    //         icon: const Icon(Icons.arrow_back),
    //         onPressed: () {
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => const Decks()),
    //           ); // ย้อนกลับไปหน้าก่อนหน้า
    //         },
    //       ),
    //       title: Text(widget.title),
    //       backgroundColor: const Color.fromARGB(255, 235, 235, 235),
    //     ),
    //     body: const Center(child: Text('Must have more than 5 cards')),
    //   );
    // 
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
        body: Column(
          children: [
            cards.isEmpty
                ? const Center(child: Text('No cards available t'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                            child: renderCardContentQ(
                                cards[currentIndex], widget.startSide)),
                        // Audio button for the main question
                        if (widget.startSide == "front" &&
                            cards[currentIndex].audioUrlFront != null &&
                            cards[currentIndex].audioUrlFront!.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              size: 40,
                              color: Color.fromARGB(255, 236, 88, 68),
                            ),
                            onPressed: () {
                              playAudio(cards[currentIndex].audioUrlFront!);
                            },
                          )
                        else if (widget.startSide == "back" &&
                            cards[currentIndex].audioUrlBack != null &&
                            cards[currentIndex].audioUrlBack!.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              size: 40,
                              color: Color.fromARGB(255, 236, 88, 68),
                            ),
                            onPressed: () {
                              playAudio(cards[currentIndex].audioUrlBack!);
                            },
                          ),

                        const SizedBox(height: 10),

                        // Grid for options
                        cards.isEmpty
                            ? const Center(child: Text('No cards available'))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columns
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options[index];
                                  bool isSelected =
                                      cards[currentIndex].selectedOption ==
                                          option.question;
                                  return GestureDetector(
                                    onTap: () {
                                      _handleAnswerSelection(option.question);
                                    },
                                    child: Center(
                                      child: Container(
                                        width: double
                                            .infinity, // Make the container take full width
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.lightBlue.shade100
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey,
                                            width: 1,
                                          ),
                                        ),

                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Center content vertically within each option
                                          children: [
                                            Expanded(
                                              child: renderCardContent(
                                                CardData(
                                                  layoutFront: option.layout,
                                                  questionFront:
                                                      option.question,
                                                  correctAnswer:
                                                      option.question,
                                                  imageUrlFront:
                                                      option.imageUrl,
                                                  audioUrlFront:
                                                      option.audioUrl,
                                                  layoutBack: option.layout,
                                                  questionBack: option.question,
                                                  imageUrlBack: option.imageUrl,
                                                  audioUrlBack: option.audioUrl,
                                                  isFlipped: false,
                                                  selectedOption:
                                                      option.question,
                                                  isAnswered:
                                                      cards[currentIndex]
                                                          .isAnswered,
                                                ),
                                                widget.startSide,
                                              ),
                                            ),

                                            // Audio button for each option
                                            if (option.audioUrl != null &&
                                                option.audioUrl!.isNotEmpty)
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.volume_up_rounded,
                                                    size: 40,
                                                    color: Color.fromARGB(
                                                        255, 236, 88, 68)),
                                                onPressed: () {
                                                  playAudio(option.audioUrl!);
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center buttons horizontally
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_circle_left_sharp,
                                  size: 45,
                                  color: Color.fromARGB(255, 126, 124, 122),
                                ),
                                onPressed: _previousCard,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_circle_right_sharp,
                                  size: 45,
                                  color: Color.fromARGB(255, 126, 124, 122),
                                ),
                                onPressed: _nextCard,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
          ],
        ));
  }
}

class CardData {
  final String? layoutFront;
  final String? questionFront;
  final String correctAnswer;
  final String? imageUrlFront;
  final String? audioUrlFront;
  final String? layoutBack;
  final String? questionBack;
  final String? imageUrlBack;
  final String? audioUrlBack;
  final bool isFlipped;
  String? selectedOption; // ใหม่: ฟิลด์เก็บคำตอบที่เลือก
  bool isAnswered; // ใหม่: ฟิลด์เช็คว่าตอบคำถามนี้แล้ว

  CardData({
    required this.layoutFront,
    required this.questionFront,
    required this.correctAnswer,
    required this.imageUrlFront,
    required this.audioUrlFront,
    required this.layoutBack,
    required this.questionBack,
    required this.imageUrlBack,
    required this.audioUrlBack,
    required this.isFlipped,
    this.selectedOption,
    this.isAnswered = false, // เริ่มต้นเป็น false
  });
}

class OptionData {
  final String layout;
  final String question;
  final String? imageUrl;
  final String? audioUrl;

  OptionData({
    required this.layout,
    required this.question,
    this.imageUrl,
    this.audioUrl,
  });
}
