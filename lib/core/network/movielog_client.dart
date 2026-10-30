import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/movielog_config.dart';

/// MovieLog 자체 API 전용 Client.
/// TMDB Client와 baseUrl·헤더·Interceptor를 공유하지 않는다.
/// 그래서 TMDB Token이 자체 서버로 전달될 일이 없다.
class MovieLogClient {
  MovieLogClient(this.dio);
  final Dio dio;
}

Dio createMovieLogDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: MovieLogConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'accept': 'application/json'},
    ),
  );

  if (kDebugMode) {
    // 헤더(인증 정보 등)는 로그에 남기지 않는다.
    dio.interceptors.add(
      LogInterceptor(requestHeader: false, responseHeader: false),
    );
  }

  return dio;
}
