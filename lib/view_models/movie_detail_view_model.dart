import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/rating_request.dart';
import '../models/tmdb_movie_dto.dart';
import '../services/rating_api_service.dart';
import 'submit_status.dart';

export 'submit_status.dart';

/// 영화 상세 화면의 상태. 영화 정보는 목록에서 넘겨받거나 Loader가 미리 불러온 값을 쓴다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this._memberId, this.movie);
  final RatingApiService _ratingService;
  final int? _memberId; // 회원가입 전이면 null

  /// 평점 저장 요청의 movieId로 쓰는 TMDB id는 movie.id다.
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  /// 결과는 [submitStatus]와 [submitMessage]로 알린다. 예외는 밖으로 던지지 않는다.
  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return; // 중복 요청 방지

    final memberId = _memberId;
    if (memberId == null) {
      submitStatus = SubmitStatus.error;
      submitMessage = '학습용 회원가입이 필요합니다.';
      notifyListeners();
      return;
    }

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      await _ratingService.createRating(
        memberId: memberId,
        request: CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      submitStatus = SubmitStatus.error;
      submitMessage = createRatingErrorMessage(error);
    } catch (_) {
      // 201이 아닌 성공 응답(StateError) 등 예상 밖의 경우도 submitting에 멈추지 않게 한다.
      submitStatus = SubmitStatus.error;
      submitMessage = '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
