import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/tmdb_genre_dto.dart';
import '../services/tmdb_movie_service.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/genre_filter_chips.dart';
import '../widgets/movie_empty_view.dart';
import '../widgets/movie_error_view.dart';
import '../widgets/movie_loading_view.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<TmdbGenreDto> _genres = const [];
  int? _selectedGenreId; // null = 전체

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await context.read<TmdbMovieService>().fetchGenres();
      if (mounted) setState(() => _genres = genres);
    } catch (_) {
      // 장르가 실패해도 영화 목록은 계속 보여 준다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PagedMoviesViewModel>();

    return Scaffold(
      appBar: AppTopBar(
        title: '영화',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '영화 검색',
            onPressed: () => context.push('/movies/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GenreFilterChips(
                genres: _genres,
                selectedGenreId: _selectedGenreId,
                enabled: true, // 이전 장르의 늦은 응답은 ViewModel이 버린다.
                onGenreSelected: (genreId) {
                  setState(() => _selectedGenreId = genreId);
                  // 장르를 바꾸면 목록을 비우고 첫 page부터 다시 불러온다.
                  context.read<PagedMoviesViewModel>().loadInitial(
                    genreId: genreId,
                  );
                },
              ),
            ),
            Expanded(
              child: switch (vm.phase) {
                LoadPhase.idle || LoadPhase.loading => const MovieLoadingView(),
                LoadPhase.error => MovieErrorView(
                  onRetry: () => context
                      .read<PagedMoviesViewModel>()
                      .loadInitial(genreId: _selectedGenreId),
                ),
                LoadPhase.empty => const MovieEmptyView(),
                LoadPhase.ready => _TmdbMovieGrid(vm: vm),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TmdbMovieGrid extends StatelessWidget {
  const _TmdbMovieGrid({required this.vm});

  final PagedMoviesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final movies = vm.movies;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.52,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => context.push('/movies/${movie.id}', extra: movie),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) => TmdbPosterImage(
                            posterPath: movie.posterPath,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('★ ${movie.voteAverage.toStringAsFixed(1)}'),
                  ],
                ),
              );
            }, childCount: movies.length),
          ),
        ),
        // 더 보기 버튼: 요청 중 로딩, 실패 시 같은 page 재시도, 마지막 page에서는 안내만.
        SliverToBoxAdapter(child: MoviePageFooter(vm: vm)),
      ],
    );
  }
}
