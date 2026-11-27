import 'package:dio/dio.dart';

import '../models/member_info.dart';

/// 로그인한 회원 본인의 정보를 다루는 서비스. 토큰이 붙는 보호 Dio를 받는다.
class MemberApiService {
  MemberApiService(this._authDio);
  final Dio _authDio;

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v8/members/me');
    return parseMemberInfo(response.data);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '/v8/members/me',
      data: {'nickname': nickname},
    );
    return parseMemberInfo(response.data);
  }
}
