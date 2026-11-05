import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// 영화 상세 화면의 별점 요약. 평균 평점을 `RatingBarIndicator`로
/// 읽기 전용 표시하고, 옆에 숫자 평점과 참여자 수를 덧붙인다.
class MovieRatingSummary extends StatelessWidget {
  const MovieRatingSummary({
    super.key,
    required this.rating,
    required this.ratingCount,
  });

  final double rating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemCount: 5,
          itemSize: 20,
          unratedColor: colors.outline.withValues(alpha: 0.3),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
