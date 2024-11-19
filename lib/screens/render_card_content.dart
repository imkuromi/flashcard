// lib/screens/render_card_content.dart

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // ใช้สำหรับ AutoSizeText
import 'package:flashcard/screens/Multiplemode.dart';

Widget renderCardContent(CardData card, String side, {String? content}) {
  final layout = side == "front" ? card.layoutFront : card.layoutBack;

  switch (layout) {
    case "text":
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: AutoSizeText(
          side == "front" ? card.questionFront ?? '' : card.questionBack ?? '',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          maxLines: 10,
          minFontSize: 10,
        ),
      );

    case "image":
      return card.imageUrlFront?.isNotEmpty == true ||
              card.imageUrlBack?.isNotEmpty == true
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                side == "front"
                    ? card.imageUrlFront ?? ''
                    : card.imageUrlBack ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Image not available',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          : const Center(child: Text('No image available'));

    case "ImageText":
      return Column(
        children: [
          Expanded(
            flex: 2, // พื้นที่สำหรับรูปภาพ
            child: card.imageUrlFront?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.network(
                      card.imageUrlFront!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Image not available'),
                    ),
                  )
                : const Center(child: Text('No image available')),
          ),
          Expanded(
            flex: 1, // พื้นที่สำหรับข้อความ
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AutoSizeText(
                side == "front"
                    ? card.questionFront ?? ''
                    : card.questionBack ?? '',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 12,
              ),
            ),
          ),
        ],
      );

    case "TextImage":
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: AutoSizeText(
                  side == "front"
                      ? card.questionFront ?? ''
                      : card.questionBack ?? '',
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.network(
                side == "front"
                    ? card.imageUrlFront ?? ''
                    : card.imageUrlBack ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Image not available',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      );

    default:
      return const Text(
        'Invalid layout',
        style: TextStyle(fontSize: 18, color: Colors.red),
        textAlign: TextAlign.center,
      );
  }
}

Widget renderCardContentQ(CardData card, String side) {
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
        padding: const EdgeInsets.only(top: 2.0),
        child: Image.network(
          side == "front" ? card.imageUrlFront ?? '' : card.imageUrlBack ?? '',
          fit: BoxFit.contain, // ควบคุมการแสดงผลให้ภาพไม่ยืด
          width: 230, // จำกัดความกว้างของภาพ
          height: 220, // จำกัดความสูงของภาพ
        ),
      );
    case "ImageText":
      return Column(
        children: [
          Image.network(
            side == "front"
                ? card.imageUrlFront ?? ''
                : card.imageUrlBack ?? '',
            fit: BoxFit.contain,
            width: 200, // จำกัดความกว้างของภาพ
            height: 180, // จำกัดความสูงของภาพ
          ),
          Text(
            side == "front"
                ? card.questionFront ?? ''
                : card.questionBack ?? '',
            style: const TextStyle(fontSize: 24),
          ),
        ],
      );
    case "TextImage":
      return Column(
        children: [
          Text(
            side == "front"
                ? card.questionFront ?? ''
                : card.questionBack ?? '',
            style: const TextStyle(fontSize: 24),
          ),
          Image.network(
            side == "front"
                ? card.imageUrlFront ?? ''
                : card.imageUrlBack ?? '',
            fit: BoxFit.contain,
            width: 200, // จำกัดความกว้างของภาพ
            height: 180, // จำกัดความสูงของภาพ
          ),
        ],
      );
    default:
      return const Text('Invalid layout');
  }
}
