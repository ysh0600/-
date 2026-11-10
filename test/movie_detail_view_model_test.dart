import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/rating_request.dart';
import 'package:movielog/services/rating_api_service.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';

class _FakeRatingService extends RatingApiService {
  _FakeRatingService() : super(Dio());

  int? gotMemberId;
  CreateRatingRequest? gotRequest;
  int? failWithStatus;
  bool unexpected = false;

  @override
  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    gotMemberId = memberId;
    gotRequest = request;
    if (unexpected) throw StateError('예상하지 못한 등록 응답: 200');
    if (failWithStatus != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: failWithStatus,
        ),
      );
    }
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

  MovieDetailViewModel viewModelFor(int? memberId) =>
      MovieDetailViewModel(ratings, memberId, _movie);

  setUp(() {
    ratings = _FakeRatingService();
  });

  test('저장 성공: 세션의 memberId와 영화 id로 요청하고 success', () async {
    final viewModel = viewModelFor(7);
    await viewModel.createRating(score: 4, comment: '좋아요');

    expect(viewModel.submitStatus, SubmitStatus.success);
    expect(ratings.gotMemberId, 7);
    expect(ratings.gotRequest!.movieId, 969681);
    expect(ratings.gotRequest!.score, 4);
    expect(ratings.gotRequest!.comment, '좋아요');
  });

  test('회원가입 전(memberId 없음)이면 요청 없이 error', () async {
    final viewModel = viewModelFor(null);
    await viewModel.createRating(score: 4);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, '학습용 회원가입이 필요합니다.');
    expect(ratings.gotRequest, isNull);
  });

  test('이미 평점을 남긴 영화(409)는 전용 문구', () async {
    final viewModel = viewModelFor(7);
    ratings.failWithStatus = 409;
    await viewModel.createRating(score: 3);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, '이미 평점을 남긴 영화입니다.');
  });

  test('그 외 서버 오류는 일반 문구', () async {
    final viewModel = viewModelFor(7);
    ratings.failWithStatus = 500;
    await viewModel.createRating(score: 3);

    expect(viewModel.submitMessage, contains('저장하지 못했습니다'));
  });

  test('201이 아닌 응답(StateError)도 error로 끝나고 멈추지 않는다', () async {
    final viewModel = viewModelFor(7);
    ratings.unexpected = true;
    await viewModel.createRating(score: 3);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.submitMessage, contains('저장하지 못했습니다'));
  });

  test('실패 뒤 다시 저장하면 이전 오류 문구가 지워진다', () async {
    final viewModel = viewModelFor(7);
    ratings.failWithStatus = 500;
    await viewModel.createRating(score: 3);
    expect(viewModel.submitStatus, SubmitStatus.error);

    ratings.failWithStatus = null;
    await viewModel.createRating(score: 3);
    expect(viewModel.submitStatus, SubmitStatus.success);
    expect(viewModel.submitMessage, isNull);
  });
}
