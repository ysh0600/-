import 'package:flutter/material.dart';

/// 영화 상세 화면 하단의 평점 남기기 버튼. 즐겨찾기는 제목 옆 FavoriteButton이 맡는다.
class MovieActionButtons extends StatelessWidget {
  const MovieActionButtons({super.key, required this.onRatePressed});

  final VoidCallback onRatePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRatePressed,
            icon: const Icon(Icons.star, size: 18),
            label: const Text('평점 남기기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
