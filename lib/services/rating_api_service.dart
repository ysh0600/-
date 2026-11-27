import 'package:dio/dio.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/common_response.dart';
import 'package:movielog/models/rating_dto.dart';
import 'package:movielog/models/rating_request.dart';

RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

/// 평점 API(v8). 조회는 공개 Dio, 등록·수정·삭제는 토큰이 붙는 Dio를 쓴다.
class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);
  final Dio _publicDio;
  final Dio _authDio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v8/members/$memberId/ratings');
    return parseRatingList(response.data); // 공개 조회: 직접 배열, 토큰 없음
  }

  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v8/ratings', data: request.toJson());
    return parseRatingResult(response.data);
  }

  // PATCH는 부분 수정이 아니라 전체 교체입니다.
  // comment를 생략하면 서버에 null로 전달되어 기존 후기가 지워집니다.
  // Dialog를 열 때 기존 score·comment를 채워서 항상 두 값을 함께 보내야 합니다.
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v8/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return parseRatingResult(response.data);
  }

  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v8/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답');
    }
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (apiErrorCode(error) == 'MEMBER404_1') return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

String createRatingErrorMessage(DioException error) {
  final code = apiErrorCode(error);
  if (error.response?.statusCode == 401) return '로그인이 필요합니다. 다시 로그인해 주세요.';
  if (code == 'MEMBER404_1') return '존재하지 않는 회원입니다.';
  if (code == 'RATING409_1') return '이미 평점을 남긴 영화입니다.';
  if (error.response?.statusCode == 400) return '평점 입력값을 다시 확인해 주세요.';
  return '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

// lib/data/services/rating_api_service.dart 에 CommonResponse와 함께 둡니다.
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

bool shouldRefreshAfterRatingError(DioException error) {
  // 403·404는 화면에 남은 목록이 서버 상태와 어긋났다는 뜻이므로 다시 조회해서 맞춥니다.
  final code = apiErrorCode(error);
  return code == 'RATING403_1' || code == 'RATING404_1';
}

bool isSessionExpiredError(DioException error) {
  final code = apiErrorCode(error);
  return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
}
