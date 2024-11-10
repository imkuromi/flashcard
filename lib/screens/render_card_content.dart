// lib/screens/render_card_content.dart

import 'package:flashcard/screens/Multiplemode.dart';
import 'package:flutter/material.dart';

Widget renderCardContent(CardData card, String side) {
  final layout = side == "front" ? card.layoutFront : card.layoutBack;

  switch (layout) {
    case "text":
      return Container(
      padding: const EdgeInsets.only(top: 70.0),
child: Text(
  side == "front" ? card.questionFront ?? '' : card.questionBack ?? '',
  style: const TextStyle(fontSize: 24),
),
      );
    case "image":
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Image.network(
          side == "front" ? card.imageUrlFront ?? '' : card.imageUrlBack ?? '',
          fit: BoxFit.contain,
        ),
      );
    case "ImageText":
      return Column(
        children: [
          Image.network(
            side == "front" ? card.imageUrlFront ?? '' : card.imageUrlBack ?? '',
            fit: BoxFit.contain,
          ),
          Text(
            side == "front" ? card.questionFront ?? '' : card.questionBack ?? '',
            style: const TextStyle(fontSize: 24),
          ),
        ],
      );
    case "TextImage":
      return Column(
        children: [
          Text(
            side == "front" ? card.questionFront ?? '' : card.questionBack ?? '',
            style: const TextStyle(fontSize: 24),
          ),
          Image.network(
            side == "front" ? card.imageUrlFront ?? '' : card.imageUrlBack ?? '',
            fit: BoxFit.contain,
          ),
        ],
      );
    default:
      return const Text('Invalid layout');
  }
}
