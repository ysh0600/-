import 'package:flutter/material.dart';

/// 별 5개를 탭해서 평점을 고르는 입력 위젯. 평점 남기기 Dialog 안에서 쓰인다.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= rating ? Icons.star : Icons.star_border,
              color: colors.primary,
              size: 32,
            ),
          ),
      ],
    );
  }
}
