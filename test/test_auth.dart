import 'package:dio/dio.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/models/login_models.dart';
import 'package:movielog/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';

/// 토큰을 메모리에만 두는 테스트용 저장소.
class MemoryTokenStorage implements TokenStorage {
  String? token;
  @override
  Future<void> saveAccessToken(String value) async => token = value;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> deleteAccessToken() async => token = null;
}

/// 서버 호출 없이 쓰는 AuthViewModel. 로그인 상태로 시작한다.
AuthViewModel makeTestAuth() {
  final auth = AuthViewModel(
    AuthApiService(Dio()),
    MemberApiService(Dio()),
    MemoryTokenStorage(),
  );
  auth.status = AuthStatus.signedIn;
  return auth;
}
