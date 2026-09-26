import 'package:flutter/material.dart';

/// 영화 목록 화면 상단의 장르 필터. 가로 ListView.builder로 Chip을 나열하고,
/// 하나를 고르면 [onGenreSelected]로 알린다.
class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  final List<String> genres;
  final String selectedGenre;
  final ValueChanged<String> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          return Padding(
            padding: EdgeInsets.only(right: index == genres.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (_) => onGenreSelected(genre),
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
