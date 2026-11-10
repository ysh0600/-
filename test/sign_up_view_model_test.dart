import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/common_response.dart';
import 'package:movielog/models/create_member_request.dart';
import 'package:movielog/models/sign_up_models.dart';
import 'package:movielog/services/sign_up_service.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

class _FakeService extends SignUpService {
  _FakeService() : super(Dio());

  bool nicknameAvailable = true;
  bool emailAvailable = true;
  bool fail = false;
  Future<CommonResponse<SignUpResult>> Function(CreateMemberRequest)? onSignUp;

  @override
  Future<CommonResponse<SignUpResult>> signUp(CreateMemberRequest request) =>
      onSignUp!(request);

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

  group('submit', () {
    const request = CreateMemberRequest(
      email: 'a@b.com',
      password: 'password123',
      nickname: 'tester',
    );

    DioException serverError(int status, Object? body) => DioException(
      requestOptions: RequestOptions(),
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: status,
        data: body,
      ),
    );

    test('성공: 응답의 memberId를 createdMemberId에 저장하고 success', () async {
      service.onSignUp = (_) async => const CommonResponse<SignUpResult>(
        isSuccess: true,
        code: 'OK',
        message: 'ok',
        result: SignUpResult(
          memberId: 42,
          email: 'a@b.com',
          nickname: 'tester',
        ),
      );

      final future = viewModel.submit(request);
      expect(viewModel.submitStatus, SubmitStatus.submitting);
      await future;

      expect(viewModel.submitStatus, SubmitStatus.success);
      expect(viewModel.createdMemberId, 42);
    });

    test('result에 memberId가 없으면 안내 문구와 함께 error', () async {
      service.onSignUp = (_) async => const CommonResponse<SignUpResult>(
        isSuccess: true,
        code: 'OK',
        message: 'ok',
      );

      await viewModel.submit(request);

      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.createdMemberId, isNull);
      expect(viewModel.snackbarMessage, contains('가입 결과를 확인하지 못했습니다'));
    });

    test('400 + 비밀번호 오류는 passwordErrorText에 표시', () async {
      service.onSignUp = (_) async => throw serverError(400, {
        'isSuccess': false,
        'code': 'BAD',
        'message': '비밀번호는 8자 이상이어야 합니다.',
      });

      await viewModel.submit(request);

      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.passwordErrorText, '비밀번호는 8자 이상이어야 합니다.');
      expect(viewModel.snackbarMessage, isNull);
    });

    test('그 외 서버 오류는 snackbarMessage로 표시', () async {
      service.onSignUp = (_) async => throw serverError(409, {
        'isSuccess': false,
        'code': 'DUP',
        'message': '이미 가입된 이메일입니다.',
      });

      await viewModel.submit(request);

      expect(viewModel.snackbarMessage, '이미 가입된 이메일입니다.');
      expect(viewModel.passwordErrorText, isNull);
    });

    test('제출 중 다시 누르면 요청을 한 번만 보낸다', () async {
      var calls = 0;
      service.onSignUp = (_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const CommonResponse<SignUpResult>(
          isSuccess: true,
          code: 'OK',
          message: 'ok',
          result: SignUpResult(
            memberId: 1,
            email: 'a@b.com',
            nickname: 'tester',
          ),
        );
      };

      final first = viewModel.submit(request);
      await viewModel.submit(request); // 제출 중이라 무시된다
      await first;

      expect(calls, 1);
    });

    test('비밀번호를 다시 입력하면 오류 문구가 지워진다', () async {
      service.onSignUp = (_) async => throw serverError(400, {
        'isSuccess': false,
        'code': 'BAD',
        'message': '비밀번호 형식이 올바르지 않습니다.',
      });
      await viewModel.submit(request);
      expect(viewModel.passwordErrorText, isNotNull);

      viewModel.onPasswordChanged();
      expect(viewModel.passwordErrorText, isNull);
    });
  });
}
