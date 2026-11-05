import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/services/member_check_service.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

class _FakeService extends MemberCheckService {
  _FakeService() : super(Dio());

  bool nicknameAvailable = true;
  bool emailAvailable = true;
  bool fail = false;

  @override
  Future<bool> checkNickname(String nickname) async {
    if (fail) throw DioException(requestOptions: RequestOptions());
    return nicknameAvailable;
  }

  @override
  Future<bool> checkEmail(String email) async {
    if (fail) throw DioException(requestOptions: RequestOptions());
    return emailAvailable;
  }
}

void main() {
  late _FakeService service;
  late SignUpViewModel viewModel;

  setUp(() {
    service = _FakeService();
    viewModel = SignUpViewModel(service);
  });

  test('닉네임: 사용 가능이면 available', () async {
    viewModel.onNicknameChanged('무비러버');
    final future = viewModel.checkNickname('무비러버');
    expect(viewModel.nicknameCheckStatus, CheckStatus.checking);
    await future;
    expect(viewModel.nicknameCheckStatus, CheckStatus.available);
    expect(viewModel.nicknameErrorText, isNull);
  });

  test('닉네임: 중복이면 duplicated, 다시 입력하면 idle', () async {
    service.nicknameAvailable = false;
    viewModel.onNicknameChanged('무비러버');
    await viewModel.checkNickname('무비러버');
    expect(viewModel.nicknameCheckStatus, CheckStatus.duplicated);
    expect(viewModel.nicknameErrorText, '이미 사용 중인 닉네임입니다.');

    viewModel.onNicknameChanged('무비러버2');
    expect(viewModel.nicknameCheckStatus, CheckStatus.idle);
    expect(viewModel.nicknameErrorText, isNull);
  });

  test('닉네임: 통신 실패와 중복은 문구가 다르다', () async {
    service.fail = true;
    viewModel.onNicknameChanged('무비러버');
    await viewModel.checkNickname('무비러버');
    expect(viewModel.nicknameCheckStatus, CheckStatus.error);
    expect(viewModel.nicknameErrorText, contains('실패'));
  });

  test('이메일: 닉네임과 같은 구조로 동작한다', () async {
    service.emailAvailable = false;
    viewModel.onEmailChanged('a@b.com');
    await viewModel.checkEmail('a@b.com');
    expect(viewModel.emailCheckStatus, CheckStatus.duplicated);
    expect(viewModel.emailErrorText, '이미 사용 중인 이메일입니다.');
    expect(viewModel.nicknameCheckStatus, CheckStatus.idle); // 서로 영향 없음

    viewModel.onEmailChanged('c@d.com');
    expect(viewModel.emailCheckStatus, CheckStatus.idle);
  });

  test('이메일: 통신 실패는 error 상태와 실패 문구', () async {
    service.fail = true;
    viewModel.onEmailChanged('a@b.com');
    await viewModel.checkEmail('a@b.com');
    expect(viewModel.emailCheckStatus, CheckStatus.error);
    expect(viewModel.emailErrorText, contains('실패'));
  });
}
