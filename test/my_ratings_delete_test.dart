import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/rating_dto.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/services/rating_api_service.dart';
import 'package:movielog/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:provider/provider.dart';

class _FakeRatings extends RatingApiService {
  _FakeRatings() : super(Dio());

  final items = <RatingDto>[
    RatingDto(
      ratingId: 1,
      movieId: 550,
      score: 5,
      comment: '최고의 영화!',
      createdAt: DateTime(2026, 11, 4),
    ),
    RatingDto(
      ratingId: 2,
      movieId: 680,
      score: 4,
      comment: null,
      createdAt: DateTime(2026, 11, 4),
    ),
  ];
  int? failDeleteWith;
  final deleted = <int>[];

  @override
  Future<List<RatingDto>> fetchMyRatings(int memberId) async => [...items];

  @override
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    if (failDeleteWith != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: failDeleteWith,
        ),
      );
    }
    deleted.add(ratingId);
    items.removeWhere((r) => r.ratingId == ratingId);
  }
}

class _FakeTmdb extends TmdbMovieService {
  _FakeTmdb() : super(Dio());

  @override
  Future<TmdbMovieDto?> findMovieById(int movieId) async => null;
}

Future<void> _pump(WidgetTester tester, _FakeRatings ratings) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<MyRatingsViewModel>(
        create: (_) => MyRatingsViewModel(ratings, _FakeTmdb(), 1)..load(),
        child: const MyRatingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('삭제를 확인하면 목록에서 사라진다', (tester) async {
    final ratings = _FakeRatings();
    await _pump(tester, ratings);
    expect(find.text('최고의 영화!'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '삭제').first);
    await tester.pumpAndSettle();
    expect(find.text('평점을 삭제할까요?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, '삭제'));
    await tester.pumpAndSettle();

    expect(ratings.deleted, [1]);
    expect(find.text('평점을 삭제할까요?'), findsNothing); // Dialog 닫힘
    expect(find.text('최고의 영화!'), findsNothing); // 목록에서 제거
  });

  testWidgets('취소하면 아무것도 삭제하지 않는다', (tester) async {
    final ratings = _FakeRatings();
    await _pump(tester, ratings);

    await tester.tap(find.widgetWithText(TextButton, '삭제').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '취소'));
    await tester.pumpAndSettle();

    expect(ratings.deleted, isEmpty);
    expect(find.text('최고의 영화!'), findsOneWidget);
  });

  testWidgets('삭제에 실패하면 스낵바를 보여주고 목록은 그대로다', (tester) async {
    final ratings = _FakeRatings()..failDeleteWith = 500;
    await _pump(tester, ratings);

    await tester.tap(find.widgetWithText(TextButton, '삭제').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '삭제'));
    await tester.pumpAndSettle();

    expect(find.text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('평점을 삭제할까요?'), findsOneWidget); // 다시 시도 가능
    expect(find.text('최고의 영화!'), findsOneWidget);
  });
}
