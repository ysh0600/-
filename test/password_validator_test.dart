import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/validators/password_validator.dart';

void main() {
  test('비어 있으면 입력 안내 문구', () {
    expect(validatePasswordFormat(null), '비밀번호를 입력해 주세요.');
    expect(validatePasswordFormat(''), '비밀번호를 입력해 주세요.');
  });

  test('8자 미만이면 길이 안내 문구', () {
    expect(validatePasswordFormat('1234567'), '비밀번호는 8자 이상 입력해 주세요.');
  });

  test('8자 이상이면 통과(null)', () {
    expect(validatePasswordFormat('12345678'), isNull);
  });
}
