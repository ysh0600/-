import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/genre_filter_chips.dart';
import '../widgets/movie_card.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String _selectedGenre = '전체';

  @override
  Widget build(BuildContext context) {
    final movies = _selectedGenre == '전체'
        ? mockMovies
        : mockMovies
              .where((movie) => movie.genres.contains(_selectedGenre))
              .toList();

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
                onGenreSelected: (genre) =>
                    setState(() => _selectedGenre = genre),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.52,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) =>
                    MovieCard(movie: movies[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
