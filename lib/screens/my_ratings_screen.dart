import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rating_with_movie.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movie_loading_view.dart';
import '../widgets/tmdb_poster_image.dart';

/// 내가 등록한 평점 목록. root Navigator 위에 올라오는 화면이라
/// 하단 NavigationBar 없이 중앙 AppBar와 BackButton만 둔다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRatingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: const Text('내가 등록한 평점'),
      ),
      body: SafeArea(
        child: switch (viewModel.status) {
          MyRatingsLoadStatus.idle ||
          MyRatingsLoadStatus.loading => const MovieLoadingView(),
          MyRatingsLoadStatus.error => _MessageView(
            icon: Icons.error_outline,
            text: viewModel.message ?? '평점을 불러오지 못했습니다.',
            onRetry: () {
              context.read<MyRatingsViewModel>().load();
            },
          ),
          MyRatingsLoadStatus.empty => const _MessageView(
            icon: Icons.star_border,
            text: '등록한 평점이 없어요',
          ),
          MyRatingsLoadStatus.success => _RatingList(
            ratings: viewModel.ratings,
            message: viewModel.message,
          ),
        },
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.ratings, this.message});

  final List<RatingWithMovie> ratings;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(message!, style: textTheme.bodySmall),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = ratings[index];
              final rating = item.rating;
              final movie = item.movie;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // 영화 정보가 없으면 posterPath가 null이라 placeholder가 나온다.
                    child: TmdbPosterImage(
                      posterPath: movie?.posterPath,
                      width: 56,
                      height: 84,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie?.title ?? '영화 #${rating.movieId}',
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('★ ${rating.score}', style: textTheme.bodyMedium),
                        if (rating.comment != null &&
                            rating.comment!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            rating.comment!,
                            style: textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(rating.createdAt),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }
}
