import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 영화 상세 화면 하단의 즐겨찾기 / 평점 남기기 버튼 Row.
class MovieActionButtons extends StatelessWidget {
  const MovieActionButtons({
    super.key,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onRatePressed,
  });

  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onRatePressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFavoritePressed,
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              size: 18,
              color: colors.primary,
            ),
            label: Text(isFavorite ? '즐겨찾기 완료' : '즐겨찾기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
