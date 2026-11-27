import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/rating_dto.dart';
import 'package:movielog/models/rating_request.dart';
import 'package:movielog/services/rating_api_service.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';

import 'test_auth.dart';

class _FakeRatingService extends RatingApiService {
  _FakeRatingService() : super(Dio(), Dio());

  CreateRatingRequest? gotRequest;
  int? failWithStatus;
  Completer<void>? gate; // 응답이 늦게 오는 상황을 만들 때 쓴다
  String? failWithCode;
  bool unexpected = false;

  @override
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    gotRequest = request;
    await gate?.future;
    if (unexpected) throw StateError('예상하지 못한 등록 응답: 200');
    if (failWithStatus != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: failWithStatus,
          data: failWithCode == null ? null : {'code': failWithCode},
        ),
      );
    }
    return RatingDto(
      ratingId: 1,
      movieId: request.movieId,
      score: request.score,
      comment: request.comment,
      createdAt: DateTime(2026, 11, 4),
    );
  }
}

const _movie = TmdbMovieDto(
  id: 969681,
  title: '테스트 영화',
  overview: '',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2026-01-01',
  genreIds: [],
  voteAverage: 8,
  popularity: 1,
);

void main() {
  late _FakeRatingService ratings;

  late AuthViewModel auth;

  MovieDetailViewModel viewModelFor() =>
      MovieDetailViewModel(ratings, auth, _movie);

  setUp(() {
    ratings = _FakeRatingService();
    auth = makeTestAuth();
  });

  test('저장 성공: 선택한 영화 id로 요청하고 success', () async {
    final viewModel = viewModelFor();
    await viewModel.createRating(score: 4, comment: '좋아요');

    expect(viewModel.submitStatus, SubmitStatus.success);
    expect(ratings.gotRequest!.movieId, 969681);
    expect(ratings.gotRequest!.score, 4);
    expect(ratings.gotRequest!.comment, '좋아요');
    expect(viewModel.createdRating?.movieId, 969681); // 응답의 Rating 객체를 보관
  });

  test('AUTH401_2면 세션을 정리하고 로그아웃 상태가 된다', () async {
    final viewModel = viewModelFor();
    ratings.failWithStatus = 401;
    ratings.failWithCode = 'AUTH401_2';
    await viewModel.createRating(score: 4);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, contains('만료'));
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.sessionExpired, isTrue);
  });

  test('403·409는 안내만 하고 로그인 상태를 유지한다', () async {
    final viewModel = viewModelFor();
    ratings.failWithStatus = 403;
    ratings.failWithCode = 'RATING403_1';
    await viewModel.createRating(score: 4);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(auth.status, AuthStatus.signedIn);
  });

  test('로그아웃 뒤 늦게 온 응답은 화면에 반영하지 않는다', () async {
    final viewModel = viewModelFor();
    ratings.gate = Completer<void>();
    final pending = viewModel.createRating(score: 4);
    await Future<void>.delayed(Duration.zero);

    await auth.logout(); // 응답이 오기 전에 로그아웃
    ratings.gate!.complete();
    await pending;

    expect(viewModel.submitStatus, isNot(SubmitStatus.success));
    expect(viewModel.createdRating, isNull);
  });

  test('이미 평점을 남긴 영화(409)는 전용 문구', () async {
    final viewModel = viewModelFor();
    ratings.failWithStatus = 409;
    ratings.failWithCode = 'RATING409_1';
    await viewModel.createRating(score: 3);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, '이미 평점을 남긴 영화입니다.');
  });

  test('그 외 서버 오류는 일반 문구', () async {
    final viewModel = viewModelFor();
    ratings.failWithStatus = 500;
    await viewModel.createRating(score: 3);

    expect(viewModel.submitMessage, contains('저장하지 못했습니다'));
  });

  test('예상 밖 응답(StateError)도 error로 끝나고 멈추지 않는다', () async {
    final viewModel = viewModelFor();
    ratings.unexpected = true;
    await viewModel.createRating(score: 3);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, contains('저장하지 못했습니다'));
  });

  test('실패 뒤 다시 저장하면 이전 오류 문구가 지워진다', () async {
    final viewModel = viewModelFor();
    ratings.failWithStatus = 500;
    await viewModel.createRating(score: 3);
    expect(viewModel.submitStatus, SubmitStatus.error);

    ratings.failWithStatus = null;
    await viewModel.createRating(score: 3);
    expect(viewModel.submitStatus, SubmitStatus.success);
    expect(viewModel.submitMessage, isNull);
  });
}
