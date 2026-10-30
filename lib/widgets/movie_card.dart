import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_theme.dart';

/// 영화 목록(GridView)에서 쓰는 카드. 포스터 위에 별점 배지를 얹고,
/// 탭하면 상세 화면(`/movies/:movieId`)으로 이동한다.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _RatingBadge(rating: movie.rating),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${movie.year} · ${movie.genres.join('/')}',
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/star.svg',
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
