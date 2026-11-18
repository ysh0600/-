import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/rating_with_movie.dart';
import '../models/tmdb_movie_dto.dart';
import '../services/rating_api_service.dart';
import '../services/tmdb_movie_service.dart';
import 'auth_view_model.dart';

const int sampleMemberId = 1; // 인증된 '내 계정'이 아닌 학습용 데이터입니다.

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this.memberId,
    this._auth,
  );
  final RatingApiService _service;
  final AuthViewModel _auth;
  final TmdbMovieService _movieService;
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  // lib/view_models/my_ratings_view_model.dart — 기존 클래스 내부에 추가합니다.
  String? refreshWarning;

  Future<void> _refreshAfterWrite() async {
    if (_disposed) return; // 화면을 떠난 뒤에는 결과를 반영하지 않는다.
    await load(); // 6주차 load()는 GET 실패를 status=error로 기록합니다.
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      notifyListeners();
    } else {
      refreshWarning = null;
    }
  }

  /// 요청 보내기 전의 세션과 지금 세션이 다르면(로그아웃·회원 전환) 응답을 버린다.
  bool _isStale(int sessionVersion) =>
      _disposed || sessionVersion != _auth.sessionVersion;

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
    } on DioException catch (error) {
      if (_isStale(sessionVersion)) return;
      if (isSessionExpiredError(error)) {
        await _auth.expireSession(); // 세션 정리 → 라우터가 /login으로 보낸다.
        return;
      }
      message = writeErrorMessage(error);
      notifyListeners();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow; // 쓰기 실패일 때만 Dialog가 실패로 처리합니다.
    }
    if (_isStale(sessionVersion)) return;
    await _refreshAfterWrite(); // GET 실패는 저장 실패로 다시 던지지 않습니다.
  }

  Future<void> deleteRating(int ratingId) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
    } on DioException catch (error) {
      if (_isStale(sessionVersion)) return;
      if (isSessionExpiredError(error)) {
        await _auth.expireSession();
        return;
      }
      message = writeErrorMessage(error);
      notifyListeners();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    if (_isStale(sessionVersion)) return;
    await _refreshAfterWrite();
  }

  // 여러 개 선택 삭제용 상태
  final Set<int> selectedRatingIds = {};
  bool isDeletingSelected = false;

  void toggleSelection(int ratingId) {
    if (isDeletingSelected) return;
    if (!selectedRatingIds.remove(ratingId)) selectedRatingIds.add(ratingId);
    notifyListeners();
  }

  Future<void> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return;
    final sessionVersion = _auth.sessionVersion;
    isDeletingSelected = true;
    notifyListeners();
    var failed = 0;
    var expired = false;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        try {
          await _service.deleteRating(ratingId);
          if (_isStale(sessionVersion)) return;
          selectedRatingIds.remove(ratingId);
        } on DioException catch (error) {
          if (_isStale(sessionVersion)) return;
          if (isSessionExpiredError(error)) {
            expired = true;
            break; // 세션이 끝났으니 나머지 삭제는 보내지 않는다.
          }
          failed++;
          // 실패한 항목은 선택 상태를 유지합니다.
        }
      }
    } finally {
      isDeletingSelected = false;
      if (!_disposed) notifyListeners(); // 예상하지 못한 오류에도 로딩을 해제합니다.
    }
    if (expired) {
      await _auth.expireSession();
      return;
    }
    if (_isStale(sessionVersion)) return;
    await _refreshAfterWrite(); // GET 실패는 삭제 성공 여부와 분리합니다.
    if (!_disposed && failed > 0) {
      message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      notifyListeners();
    }
  }

  Future<void> load() async {
    final version = ++_requestVersion;
    final sessionVersion = _auth.sessionVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_isStale(sessionVersion) || version != _requestVersion) return;
      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      // 같은 movieId는 캐시를 사용하고, 영화 조회 실패가 평점 목록을 지우지 않습니다.
      for (final rating in rawRatings) {
        if (_isStale(sessionVersion) || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않습니다. 다음 로딩에서 재시도합니다.
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }
      if (_isStale(sessionVersion) || version != _requestVersion) return;
      ratings = entries;
      final ids = entries.map((e) => e.rating.ratingId).toSet();
      selectedRatingIds.retainWhere(ids.contains);
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_isStale(sessionVersion) || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
