import 'package:flutter/material.dart';

import '../models/tmdb_genre_dto.dart';

/// 영화 목록 화면 상단의 장르 필터. 가로 ListView.builder로 Chip을 나열하고,
/// 하나를 고르면 [onGenreSelected]로 알린다.
class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onGenreSelected,
    this.enabled = true,
  });

  final List<TmdbGenreDto> genres;
  final int? selectedGenreId; // null = 전체
  final ValueChanged<int?> onGenreSelected;

  /// false면 Chip을 눌러도 반응하지 않는다(요청 중 장르 변경 방지).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length + 1,
        itemBuilder: (context, index) {
          final genre = index == 0 ? null : genres[index - 1]; // null = 전체
          final isSelected = genre?.id == selectedGenreId;

          return Padding(
            padding: EdgeInsets.only(right: index == genres.length ? 0 : 8),
            child: ChoiceChip(
              label: Text(genre?.name ?? '전체'),
              selected: isSelected,
              onSelected: enabled ? (_) => onGenreSelected(genre?.id) : null,
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              side: BorderSide(
                color: isSelected ? colors.primary : colors.outline,
              ),
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: isSelected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}
