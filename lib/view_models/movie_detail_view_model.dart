import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/rating_dto.dart';
import '../models/rating_request.dart';
import '../models/tmdb_movie_dto.dart';
import '../services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'submit_status.dart';

export 'submit_status.dart';

/// 영화 상세 화면의 상태. 영화 정보는 목록에서 넘겨받거나 Loader가 미리 불러온 값을 쓴다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this._auth, this.movie);
  final RatingApiService _ratingService;
  final AuthViewModel _auth;

  /// 평점 저장 요청의 movieId로 쓰는 TMDB id는 movie.id다.
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;

  /// 등록 성공 응답(result)으로 받은 Rating. 저장 전이나 실패하면 null.
  RatingDto? createdRating;
  bool _disposed = false;

  /// 결과는 [submitStatus]와 [submitMessage]로 알린다. 예외는 밖으로 던지지 않는다.
  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return; // 중복 요청 방지

    final sessionVersion = _auth.sessionVersion; // 요청 보내기 전의 세션
    bool isStale() => _disposed || sessionVersion != _auth.sessionVersion;

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    createdRating = null;
    notifyListeners();

    try {
      final created = await _ratingService.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (isStale()) return; // 로그아웃·회원 전환 뒤 늦게 온 응답은 반영하지 않는다.
      createdRating = created;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (isStale()) return;
      submitStatus = SubmitStatus.error;
      if (isSessionExpiredError(error)) {
        submitMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        notifyListeners();
        await _auth.expireSession(); // 세션 정리 → 라우터가 /login으로 보낸다.
        return;
      }
      // 403·409 등은 안내만 하고 로그인 상태를 유지한다.
      submitMessage = createRatingErrorMessage(error);
    } catch (_) {
      if (isStale()) return;
      // 예상 밖의 응답(StateError) 등도 submitting에 멈추지 않게 한다.
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
