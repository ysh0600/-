import 'package:dio/dio.dart';
import 'package:movielog/models/favorite_check_dto.dart';
import 'package:movielog/models/favorite_response_dto.dart';
import 'package:movielog/services/favorite_api_service.dart';

/// 서버 없이 쓰는 즐겨찾기 API. failWith가 있으면 그 status·code로 실패한다.
class FakeFavoriteApi extends FavoriteApiService {
  FakeFavoriteApi() : super(Dio());

  bool isFavorite = false;
  int? failWithStatus;
  String? failWithCode;
  int addCalls = 0;

  DioException _error() => DioException(
    requestOptions: RequestOptions(),
    response: Response(
      requestOptions: RequestOptions(),
      statusCode: failWithStatus,
      data: failWithCode == null ? null : {'code': failWithCode},
    ),
  );

  @override
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    if (failWithStatus != null) throw _error();
    return FavoriteCheckDto(movieId: movieId, isFavorite: isFavorite);
  }

  @override
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    addCalls++;
    if (failWithStatus != null) throw _error();
    isFavorite = true;
    return FavoriteResponseDto(
      favoriteId: 1,
      movieId: movieId,
      createdAt: DateTime(2026, 11, 4),
    );
  }

  @override
  Future<void> deleteFavorite({required int movieId}) async {
    if (failWithStatus != null) throw _error();
    isFavorite = false;
  }
}
