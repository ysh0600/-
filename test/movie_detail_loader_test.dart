import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/movie_detail_loader.dart';
import 'package:movielog/services/rating_api_service.dart';
import 'package:movielog/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

const _movie = TmdbMovieDto(
  id: 5,
  title: '목록에서 온 영화',
  overview: '줄거리입니다',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2026-02-03',
  genreIds: [],
  voteAverage: 7,
  popularity: 1,
);

class _FakeTmdb extends TmdbMovieService {
  _FakeTmdb({this.fail = false}) : super(Dio());
  final bool fail;
  int fetchCount = 0;

  @override
  Future<TmdbMovieDto> fetchMovieDetail(int movieId) async {
    fetchCount++;
    if (fail) throw Exception('network');
    return _movie;
  }
}

Widget _app(_FakeTmdb tmdb, {TmdbMovieDto? initial}) => MultiProvider(
  providers: [
    Provider<TmdbMovieService>.value(value: tmdb),
    Provider<RatingApiService>.value(value: RatingApiService(Dio())),
    ChangeNotifierProvider<LearningMemberSession>(
      create: (_) => LearningMemberSession(),
    ),
  ],
  child: MaterialApp(
    home: MovieDetailLoader(movieId: 5, initialMovie: initial),
  ),
);

void main() {
  testWidgets('목록에서 영화를 넘겨받으면 다시 불러오지 않고 바로 보여준다', (tester) async {
    final tmdb = _FakeTmdb();
    await tester.pumpWidget(_app(tmdb, initial: _movie));
    await tester.pumpAndSettle();

    expect(tmdb.fetchCount, 0);
    expect(find.text('줄거리입니다'), findsOneWidget);
  });

  testWidgets('주소로 직접 들어오면 TMDB에서 불러와 보여준다', (tester) async {
    final tmdb = _FakeTmdb();
    await tester.pumpWidget(_app(tmdb));
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // 로딩

    await tester.pumpAndSettle();
    expect(tmdb.fetchCount, 1);
    expect(find.text('줄거리입니다'), findsOneWidget);
  });

  testWidgets('불러오기에 실패하면 안내 문구', (tester) async {
    await tester.pumpWidget(_app(_FakeTmdb(fail: true)));
    await tester.pumpAndSettle();

    expect(find.text('영화를 불러오지 못했습니다.'), findsOneWidget);
  });
}
