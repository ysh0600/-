import 'package:flutter/foundation.dart';

import '../models/tmdb_movie_detail_dto.dart';
import '../services/tmdb_movie_service.dart';

enum MovieDetailLoadStatus { idle, loading, success, error }

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._service, this.movieId);
  final TmdbMovieService _service;

  /// 목록 카드에서 넘겨받은 TMDB id. 평점 Dialog에도 이 값을 전달한다.
  final int movieId;

  TmdbMovieDetailDto? movie;
  MovieDetailLoadStatus status = MovieDetailLoadStatus.idle;

  Future<void> load() async {
    status = MovieDetailLoadStatus.loading;
    notifyListeners();

    try {
      movie = await _service.fetchMovieDetail(movieId);
      status = MovieDetailLoadStatus.success;
    } catch (_) {
      status = MovieDetailLoadStatus.error;
    }
    notifyListeners();
  }
}
