import 'package:flutter/foundation.dart';

import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_dto.dart';
import '../services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  static const _maxMovies = 30;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId; // null = 전체
  MovieListLoadStatus status = MovieListLoadStatus.idle;

  bool get isLoading => status == MovieListLoadStatus.loading;

  Future<void> loadInitial() async {
    await _loadGenres();
    await load();
  }

  Future<void> _loadGenres() async {
    try {
      genres = await _service.fetchGenres();
    } catch (_) {
      genres = const []; // 장르가 실패해도 영화 목록은 계속 보여준다
    }
    notifyListeners();
  }

  /// 장르를 바꾸고 page 1부터 다시 요청한다. null은 "전체"(with_genres 없음).
  /// Discover 요청 중에는 장르를 바꾸지 못한다.
  Future<void> selectGenre(int? genreId) async {
    if (isLoading || genreId == selectedGenreId) return;
    selectedGenreId = genreId;
    await load();
  }

  Future<void> load() async {
    if (isLoading) return;
    status = MovieListLoadStatus.loading;
    notifyListeners(); // 상태가 바뀌었음을 구독자에게 알린다.

    try {
      final byId = <int, TmdbMovieDto>{}; // TMDB id 기준 중복 제거
      var page = 1;
      var totalPages = 1;

      while (byId.length < _maxMovies && page <= totalPages) {
        final result = await _service.discoverMovies(
          page: page,
          genreId: selectedGenreId,
        );
        totalPages = result.totalPages;

        for (final movie in result.results) {
          byId.putIfAbsent(movie.id, () => movie);
          if (byId.length >= _maxMovies) break;
        }
        page++;
      }

      movies = byId.values.toList();
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (_) {
      status = MovieListLoadStatus.error;
    }
    notifyListeners();
  }
}
