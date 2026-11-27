import 'package:dio/dio.dart';

import '../data/common_response.dart';
import '../models/check_result.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

/// 회원가입 화면에서 쓰는 서버 호출 모음. (구 MemberCheckService)
class SignUpService {
  SignUpService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v6/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v6/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post('/v6/members', data: request.toJson());

    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

/// 회원가입 실패 응답의 message를 화면에 보여줄 문구로 바꾼다.
/// 서버가 CommonResponse 모양이 아닌 오류(예: 404 본문)를 줘도 예외 없이 기본 문구를 쓴다.
String writeSignUpErrorMessage(DioException error) {
  const fallback = '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return fallback;

  try {
    final common = CommonResponse<Object?>.fromJson(data, (value) => value);
    return common.message;
  } catch (_) {
    return fallback;
  }
}
