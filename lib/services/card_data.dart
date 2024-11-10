// lib/models/card_data.dart
class CardData {
  final String layoutFront;
  final String questionFront;
  final String imageUrlFront;
  final String audioUrlFront;
  final String layoutBack;
  final String questionBack;
  final String imageUrlBack;
  final String audioUrlBack;
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
    this.isFlipped = false,
  });
}
