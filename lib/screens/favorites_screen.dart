import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tmdb_movie_dto.dart';
import '../models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoritesViewModel>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('내 즐겨찾기'), centerTitle: true),
    body: Consumer<FavoritesViewModel>(
      builder: (context, vm, _) {
        if (vm.phase == LoadPhase.idle || vm.phase == LoadPhase.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.phase == LoadPhase.empty) {
          return const Center(child: Text('아직 즐겨찾기한 영화가 없습니다.'));
        }

        if (vm.phase == LoadPhase.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vm.errorMessage ?? '조회 오류입니다.'),
                MovieLogButton(label: '다시 시도', onPressed: vm.refresh),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: vm.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = vm.items[index], movie = item.movie;

              if (movie == null) {
                return _FavoriteCardFrame(
                  child: ListTile(
                    leading: const Icon(Icons.broken_image_outlined),
                    title: Text('TMDB #${item.favorite.movieId}'),
                    subtitle: Text(item.errorMessage ?? '정보가 없습니다.'),
                    trailing: MovieLogButton(
                      width: 110,
                      label: '정보 재조회',
                      onPressed: vm.refresh,
                    ),
                  ),
                );
              }

              return _FavoriteCardFrame(
                onTap: () async {
                  await widget.onOpenMovie(movie);

                  if (!mounted) return;

                  await vm.refresh(); // ViewModel도 같은 현재 세션인지 다시 확인합니다.
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TmdbPosterImage(
                          posterPath: movie.posterPath,
                          width: 80,
                          height: 120,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text('TMDB 영화 ID로 연결합니다.'),
                            const SizedBox(height: 8),
                            Text(
                              '즐겨찾기한 영화',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

/// 테두리가 있는 둥근 카드 틀. onTap이 있으면 눌렀을 때 반응한다.
class _FavoriteCardFrame extends StatelessWidget {
  const _FavoriteCardFrame({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primaryContainer, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
