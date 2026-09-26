import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/genre_chips.dart';
import '../widgets/movie_action_buttons.dart';
import '../widgets/movie_rating_input.dart';
import '../widgets/movie_rating_summary.dart';
import '../widgets/share_bottom_sheet.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  int _rating = 0;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요')),
    );
  }

  Future<void> _openRatingDialog(Movie movie) async {
    var tempRating = _rating;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('평점 남기기'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(movie.title, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  MovieRatingInput(
                    rating: tempRating,
                    onChanged: (value) {
                      setDialogState(() => tempRating = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _rating = tempRating);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('평점 $tempRating점을 남겼어요')),
                    );
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('영화를 찾을 수 없어요')),
        body: const Center(child: Text('존재하지 않는 영화입니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/share.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
            ),
            tooltip: '공유',
            onPressed: () => ShareBottomSheet.show(context, movie.title),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                movie.posterAsset,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      '${movie.year} · ${movie.genres.join('/')} · ${movie.runtimeMinutes}분',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MovieRatingSummary(
                      rating: movie.rating,
                      ratingCount: movie.ratingCount,
                    ),
                    const SizedBox(height: 16),
                    GenreChips(genres: movie.genres),
                    const SizedBox(height: 24),
                    Text('시놉시스', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      movie.synopsis,
                      style: textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: MovieActionButtons(
            isFavorite: _isFavorite,
            onFavoritePressed: _toggleFavorite,
            onRatePressed: () => _openRatingDialog(movie),
          ),
        ),
      ),
    );
  }
}
