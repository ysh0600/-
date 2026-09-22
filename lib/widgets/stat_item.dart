import 'package:flutter/material.dart';

/// "본 영화 / 평점 / 즐겨찾기"처럼 라벨 + 값 한 쌍을 보여주는
/// 재사용 가능한 통계 카드. ProfileStats에서 3번 재사용된다.
class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      // Padding: 카드 "안쪽" 여백 (테두리와 텍스트 사이 간격)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}
