import 'package:flutter_dotenv/flutter_dotenv.dart';

/// MovieLog 자체 API 설정. TMDB 설정(TmdbConfig)과 분리해서 관리한다.
abstract final class MovieLogConfig {
  // TODO(5주차 유저별 평점 API): 실제 서버 주소를 .env의 MOVIELOG_API_BASE_URL에 넣는다.
  static String get baseUrl =>
      dotenv.env['MOVIELOG_API_BASE_URL'] ?? 'http://localhost:8080';
}
