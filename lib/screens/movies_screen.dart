import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/genre_filter_chips.dart';
import '../widgets/movie_empty_view.dart';
import '../widgets/movie_error_view.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_loading_view.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  static const _genreKey = 'last_selected_genre';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final FakeMovieService _movieService = FakeMovieService();
  late Future<List<Movie>> _moviesFuture;
  String _selectedGenre = '전체';

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.fetchMovies();
    _loadSelectedGenre();
  }

  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies();
    });
  }

  Future<void> _loadSelectedGenre() async {
    final saved = await _prefs.getString(_genreKey);
    if (!mounted || saved == null) return;
    if (saved != '전체' && !allGenres.contains(saved)) return;
    setState(() => _selectedGenre = saved);
  }

  void _onGenreSelected(String genre) {
    setState(() => _selectedGenre = genre);
    _prefs.setString(_genreKey, genre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: '영화'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GenreFilterChips(
                genres: allGenres,
                selectedGenre: _selectedGenre,
                onGenreSelected: _onGenreSelected,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MovieLoadingView();
                  }
                  if (snapshot.hasError) {
                    return MovieErrorView(onRetry: _retry);
                  }

                  final allMovies = snapshot.data ?? [];
                  final movies = _selectedGenre == '전체'
                      ? allMovies
                      : allMovies
                            .where(
                              (movie) => movie.genres.contains(_selectedGenre),
                            )
                            .toList();

                  if (movies.isEmpty) {
                    return const MovieEmptyView();
                  }
                  return MovieGrid(movies: movies);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
