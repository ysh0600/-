import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/tmdb_movie_detail_dto.dart';
import '../view_models/movie_detail_view_model.dart';
import '../widgets/genre_chips.dart';
import '../widgets/movie_action_buttons.dart';
import '../widgets/movie_error_view.dart';
import '../widgets/movie_loading_view.dart';
import '../widgets/movie_rating_input.dart';
import '../widgets/movie_rating_summary.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

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

  Future<void> _openRatingDialog(TmdbMovieDetailDto movie) async {
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
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;

    return switch (viewModel.status) {
      MovieDetailLoadStatus.idle || MovieDetailLoadStatus.loading => Scaffold(
        appBar: AppBar(),
        body: const MovieLoadingView(),
      ),
      MovieDetailLoadStatus.error => Scaffold(
        appBar: AppBar(),
        body: MovieErrorView(
          onRetry: () {
            context.read<MovieDetailViewModel>().load();
          },
        ),
      ),
      MovieDetailLoadStatus.success => _buildDetail(context, movie!),
    };
  }

  Widget _buildDetail(BuildContext context, TmdbMovieDetailDto movie) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final year = (movie.releaseDate ?? '').split('-').first;
    final genreNames = movie.genres.map((genre) => genre.name).toList();
    final info = [
      if (year.isNotEmpty) year,
      if (genreNames.isNotEmpty) genreNames.join('/'),
      if (movie.runtime != null && movie.runtime! > 0) '${movie.runtime}분',
    ].join(' · ');

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
              TmdbPosterImage(
                posterPath: movie.posterPath,
                width: double.infinity,
                height: 320,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      info,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MovieRatingSummary(
                      // TMDB 평점은 10점 만점이라 별 5개 기준으로 환산한다.
                      rating: movie.voteAverage / 2,
                      ratingCount: movie.voteCount,
                    ),
                    const SizedBox(height: 16),
                    GenreChips(genres: genreNames),
                    const SizedBox(height: 24),
                    Text('시놉시스', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isEmpty ? '등록된 줄거리가 없어요.' : movie.overview,
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
