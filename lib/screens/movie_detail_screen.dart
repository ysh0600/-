import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_detail_view_model.dart';
import '../widgets/movie_action_buttons.dart';
import '../widgets/movie_rating_summary.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요')),
    );
  }

  Future<void> _openRatingDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          final viewModel = context.read<MovieDetailViewModel>();
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = context.read<MovieDetailViewModel>().movie;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final year = (movie.releaseDate ?? '').split('-').first;
    final info = [
      if (year.isNotEmpty) year,
      '★ ${movie.voteAverage.toStringAsFixed(1)}',
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
                    // TMDB 평점은 10점 만점이라 별 5개 기준으로 환산한다.
                    MovieRatingSummary(rating: movie.voteAverage / 2),
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
            onRatePressed: _openRatingDialog,
          ),
        ),
      ),
    );
  }
}
