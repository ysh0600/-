import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/tmdb_movie_dto.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/genre_filter_chips.dart';
import '../widgets/movie_empty_view.dart';
import '../widgets/movie_error_view.dart';
import '../widgets/movie_loading_view.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieListViewModel>();

    return Scaffold(
      appBar: const AppTopBar(title: '영화'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GenreFilterChips(
                genres: viewModel.genres,
                selectedGenreId: viewModel.selectedGenreId,
                enabled: !viewModel.isLoading,
                onGenreSelected: (genreId) {
                  context.read<MovieListViewModel>().selectGenre(genreId);
                },
              ),
            ),
            Expanded(
              child: switch (viewModel.status) {
                MovieListLoadStatus.idle ||
                MovieListLoadStatus.loading => const MovieLoadingView(),
                MovieListLoadStatus.error => MovieErrorView(
                  onRetry: () {
                    context.read<MovieListViewModel>().load();
                  },
                ),
                MovieListLoadStatus.empty => const MovieEmptyView(),
                MovieListLoadStatus.success => _TmdbMovieGrid(
                  movies: viewModel.movies,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TmdbMovieGrid extends StatelessWidget {
  const _TmdbMovieGrid({required this.movies});

  final List<TmdbMovieDto> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
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
              Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text('★ ${movie.voteAverage.toStringAsFixed(1)}'),
            ],
          ),
        );
      },
    );
  }
}
