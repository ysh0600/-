import '../data/mock_movies.dart';
import '../models/movie.dart';

enum FakeMovieMode { success, empty, error }

class FakeMovieService {
  FakeMovieService({this.mode = FakeMovieMode.success});

  final FakeMovieMode mode;

  // TODO(5주차 유저별 평점 조회 API): 실제 API로 교체
  Future<List<Movie>> fetchMovies() async {
    await Future.delayed(const Duration(seconds: 1));

    switch (mode) {
      case FakeMovieMode.success:
        return mockMovies;
      case FakeMovieMode.empty:
        return [];
      case FakeMovieMode.error:
        throw Exception('Fake network error');
    }
  }
}
