import 'package:flashcard/screens/Multiplemode.dart';
import 'package:flashcard/screens/Singlemode.dart';
import 'package:flutter/material.dart';

class OptionPlay extends StatefulWidget {
  final String deckId;
  final String title;
  final int cardCount; // จำนวนการ์ดทั้งหมดใน deck
  final int enterCard; // จำนวนการ์ดที่ต้องการเล่น

  const OptionPlay({
    Key? key,
    required this.deckId,
    required this.title,
    required this.cardCount,
    required this.enterCard,
  }) : super(key: key);

  @override
  _OptionPlayState createState() => _OptionPlayState();
}

class _OptionPlayState extends State<OptionPlay> {
  bool isSingleMode = true;
  bool isMultipleMode = false;
  bool isStartFront = true;

  final TextEditingController questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionController.text =
        '${widget.cardCount}'; // แสดงจำนวนการ์ดทั้งหมดโดยค่าเริ่มต้น
  }

  void _navigateToMode() {
    int enteredCardCount = int.tryParse(questionController.text) ?? 0;

    if (isSingleMode) {
      // ตรวจสอบให้แน่ใจว่าจำนวนการ์ดที่กรอกถูกต้อง
      if (enteredCardCount > 0 && enteredCardCount <= widget.cardCount) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Singlemode(
              deckId: widget.deckId,
              title: widget.title,
              startSide: isStartFront ? 'front' : 'back',
              friendId: '',
              enterCard: enteredCardCount, // ส่งค่าจำนวนการ์ดที่กรอก
              cardCount: widget.cardCount, // จำนวนการ์ดทั้งหมดใน deck
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number of cards')),
        );
      }
    } else if (isMultipleMode) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultipleMode(
              deckId: widget.deckId,
              title: widget.title,
              startSide: isStartFront ? 'front' : 'back',
              friendId: '',
              enterCard: enteredCardCount, // ส่งค่าจำนวนการ์ดที่กรอก
              cardCount: widget.cardCount, // จำนวนการ์ดทั้งหมดใน deck
            ),
          ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 26,
              color: Colors.black, // Set text color to black
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0, // Letter spacing
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Options Play',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black, // Set text color to black
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0, // Font weight
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Select Mode',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black, // Set text color to black
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0, // Font weight
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isSingleMode,
                            onChanged: (value) {
                              setState(() {
                                isSingleMode = value ?? false;
                                if (isSingleMode) {
                                  isMultipleMode = false;
                                }
                              });
                            },
                          ),
                          const Text(
                            'Single mode',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Set text color to black
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0, // Font weight
                            ),
                          ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: isMultipleMode,
                            onChanged: (value) {
                              setState(() {
                                isMultipleMode = value ?? false;
                                if (isMultipleMode) {
                                  isSingleMode = false;
                                }
                              });
                            },
                          ),
                          const Text(
                            'Multiple mode',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Set text color to black
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0, // Font weight
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Start Side',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black, // Set text color to black
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0, // Font weight
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isStartFront,
                            onChanged: (value) {
                              setState(() {
                                isStartFront = value ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Front',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black, // Set text color to black
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0, // Font weight
                            ),
                          ),
                          const SizedBox(width: 70),
                          Checkbox(
                            value: !isStartFront,
                            onChanged: (value) {
                              setState(() {
                                isStartFront = !(value ?? true);
                              });
                            },
                          ),
                          const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black, // Set text color to black
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0, // Font weight
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Question (max ${widget.cardCount}) :',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black, // Set text color to black
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0, // Font weight
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: questionController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a number';
                                }
                                final enteredValue = int.tryParse(value);
                                if (enteredValue == null || enteredValue <= 0) {
                                  return 'Please enter a valid number';
                                } else if (enteredValue > widget.cardCount) {
                                  return 'Cannot exceed ${widget.cardCount} cards';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  _navigateToMode(); // Your navigation function
                },
                icon: const Icon(
                  Icons.play_circle_filled_rounded,
                  size: 50,
                  color: Color.fromARGB(255, 193, 70, 62),
                ),
                label: const Text(
                  'Start ',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black, // Set text color to black
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0, // Font weight
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  backgroundColor:
                      Colors.white, // Optional: Change button background color
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}