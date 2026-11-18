/// 비밀번호 형식 검사. 통과하면 null, 아니면 화면에 보여줄 문구를 돌려준다.
/// 지금은 가입 화면이 쓰던 규칙(8자 이상)만 확인한다.
/// 서버가 더 엄격한 규칙을 요구하면 400 응답의 문구가 passwordErrorText로 표시된다.
String? validatePasswordFormat(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return '비밀번호를 입력해 주세요.';
  if (password.length < 8) return '비밀번호는 8자 이상 입력해 주세요.';
  return null;
}
