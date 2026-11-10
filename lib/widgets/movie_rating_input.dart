import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

/// 별 5개를 탭해서 평점을 고르는 입력 위젯. 평점 남기기 Dialog 안에서 쓰인다.
/// [enabled]가 false면 저장 요청 중 등에 별을 바꾸지 못하게 막는다.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false,
      ignoreGestures: !enabled,
      itemCount: 5,
      itemSize: 40,
      itemBuilder: (context, index) =>
          const Icon(Icons.star, color: AppColors.primary),
      onRatingUpdate: onChanged,
    );
  }
}
