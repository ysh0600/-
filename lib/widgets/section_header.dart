import 'package:flutter/material.dart';

/// "인기 영화 / 전체보기 >" 처럼 제목과 보조 액션을 나란히 보여주는 섹션 헤더.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textTheme.titleMedium),
        TextButton(onPressed: onActionPressed, child: Text(actionLabel)),
      ],
    );
  }
}
