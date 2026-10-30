import '../data/mock_movies.dart';
import '../models/movie.dart';

enum FakeMovieMode { success, empty, error, failOnce }

class FakeMovieService {
  FakeMovieService({this.mode = FakeMovieMode.success});

  final FakeMovieMode mode;
  int _callCount = 0;

  // TODO(5주차 유저별 평점 조회 API): 실제 API로 교체
  Future<List<Movie>> fetchMovies() async {
    _callCount++;
    await Future.delayed(const Duration(seconds: 1));

    switch (mode) {
      case FakeMovieMode.success:
        return mockMovies;
      case FakeMovieMode.empty:
        return [];
      case FakeMovieMode.error:
        throw Exception('Fake network error');
      case FakeMovieMode.failOnce:
        // 첫 호출만 실패하고, 재시도부터는 성공
        if (_callCount == 1) throw Exception('Fake network error');
        return mockMovies;
    }
  }
}
