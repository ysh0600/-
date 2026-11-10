import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/services/sign_up_service.dart';

DioException _error(Object? body) => DioException(
  requestOptions: RequestOptions(),
  response: Response(requestOptions: RequestOptions(), data: body),
);

void main() {
  test('CommonResponse 오류는 서버 message를 그대로 쓴다', () {
    final error = _error({
      'isSuccess': false,
      'code': 'MEMBER_409',
      'message': '이미 사용 중인 이메일입니다.',
      'result': null,
    });

    expect(writeSignUpErrorMessage(error), '이미 사용 중인 이메일입니다.');
  });

  test('CommonResponse 모양이 아닌 오류 본문은 기본 문구', () {
    final error = _error({'message': 'Not Found', 'statusCode': 404});

    expect(writeSignUpErrorMessage(error), contains('회원가입에 실패했습니다'));
  });

  test('본문이 없거나 문자열이면 기본 문구', () {
    expect(writeSignUpErrorMessage(_error(null)), contains('회원가입에 실패했습니다'));
    expect(
      writeSignUpErrorMessage(_error('Bad Gateway')),
      contains('회원가입에 실패했습니다'),
    );
  });
}
