import 'package:flutter/material.dart';

void main() {
  runApp(const Singlemode());
}

class Singlemode extends StatelessWidget {
  const Singlemode({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Flip',
      home: CardFlipScreen(),
    );
  }
}

class CardFlipScreen extends StatefulWidget {
  @override
  _CardFlipScreenState createState() => _CardFlipScreenState();
}

class _CardFlipScreenState extends State<CardFlipScreen> {
  final List<CardData> cards = List.generate(
    10,
    (index) => CardData('Front $index', 'Back $index'),
  );

  int currentIndex = 0;

  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
    });
  }

  void _previousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + cards.length) % cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Flip')),
      body: GestureDetector(
        onTap: () {
          setState(() {
            cards[currentIndex].isFlipped = !cards[currentIndex].isFlipped;
          });
        },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            _previousCard();
          } else {
            _nextCard();
          }
        },
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: cards[currentIndex].isFlipped
                ? Card(
                    key: ValueKey('back${currentIndex}'),
                    color: Colors.teal,
                    child: Center(
                      child: Text(
                        cards[currentIndex].back,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  )
                : Card(
                    key: ValueKey('front${currentIndex}'),
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        cards[currentIndex].front,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class CardData {
  final String front;
  final String back;
  bool isFlipped;

  CardData(this.front, this.back, {this.isFlipped = false});
}
