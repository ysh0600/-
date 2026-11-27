import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/session/session_guard.dart';
import '../core/utils/map_bounded.dart';
import '../core/utils/safe_notify.dart';
import '../data/favorite_list_item.dart';
import '../services/favorite_api_service.dart';
import '../services/rating_api_service.dart' show isSessionExpiredError;
import '../services/tmdb_movie_service.dart';
import '../view_models/load_phase.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    required this.onSessionExpired,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;
  final String accountId;

  /// 토큰 만료(AUTH401_2/3/4)일 때 세션을 정리하는 함수. 403·네트워크 실패에는 부르지 않는다.
  final Future<void> Function() onSessionExpired;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;
  int _refreshGeneration = 0;

  // 즐겨찾기 목록을 다시 조회하고 TMDB 영화 정보를 최대 5개씩 보충합니다.
  Future<void> refresh() async {
    final sessionGeneration = sessionGuard.generation;
    if (!sessionGuard.isCurrent(sessionGeneration, accountId) || isDisposed) {
      return;
    }
    final refreshGeneration = ++_refreshGeneration;
    phase = LoadPhase.loading;
    errorMessage = null;
    notifyIfAlive();
    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (!sessionGuard.isCurrent(sessionGeneration, accountId) ||
          refreshGeneration != _refreshGeneration ||
          isDisposed) {
        return;
      }
      final enriched = await mapBounded(favorites, enrichmentConcurrency, (
        favorite,
      ) async {
        try {
          final movie = await tmdbApi.fetchMovieDetail(favorite.movieId);
          return FavoriteListItem(favorite: favorite, movie: movie);
        } catch (_) {
          return FavoriteListItem(
            favorite: favorite,
            errorMessage: '영화 정보를 불러오지 못했습니다.',
          );
        }
      });
      if (!sessionGuard.isCurrent(sessionGeneration, accountId) ||
          refreshGeneration != _refreshGeneration ||
          isDisposed) {
        return;
      }
      items = enriched;
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } on DioException catch (error) {
      if (!sessionGuard.isCurrent(sessionGeneration, accountId) ||
          refreshGeneration != _refreshGeneration ||
          isDisposed) {
        return;
      }
      if (isSessionExpiredError(error)) {
        await onSessionExpired(); // 세션 정리 → 라우터가 /login으로 보낸다.
        return;
      }
      phase = LoadPhase.error;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
    } catch (_) {
      if (!sessionGuard.isCurrent(sessionGeneration, accountId) ||
          refreshGeneration != _refreshGeneration ||
          isDisposed) {
        return;
      }
      phase = LoadPhase.error;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
    } finally {
      if (sessionGuard.isCurrent(sessionGeneration, accountId) &&
          refreshGeneration == _refreshGeneration &&
          !isDisposed) {
        notifyIfAlive();
      }
    }
  }
}
