import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/common_response.dart';
import 'package:movielog/models/create_member_request.dart';
import 'package:movielog/models/sign_up_models.dart';
import 'package:movielog/screens/register_screen.dart';
import 'package:movielog/services/sign_up_service.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

class _FakeService extends SignUpService {
  _FakeService() : super(Dio());

  Future<CommonResponse<SignUpResult>> Function(CreateMemberRequest)? onSignUp;
  CreateMemberRequest? sent;

  @override
  Future<bool> checkNickname(String nickname) async => true;

  @override
  Future<bool> checkEmail(String email) async => true;

  @override
  Future<CommonResponse<SignUpResult>> signUp(CreateMemberRequest request) {
    sent = request;
    return onSignUp!(request);
  }
}

Future<LearningMemberSession> _pumpAndFill(
  WidgetTester tester,
  _FakeService service,
) async {
  final session = LearningMemberSession();
  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/movies',
        builder: (_, _) => const Scaffold(body: Text('영화 목록 화면')),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<SignUpService>.value(value: service),
        ChangeNotifierProvider<LearningMemberSession>.value(value: session),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await tester.enterText(find.widgetWithText(TextFormField, '닉네임'), 'tester');
  await tester.enterText(
    find.widgetWithText(TextFormField, '이메일'),
    ' a@b.com ',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '비밀번호'),
    'password123',
  );
  await tester.pump();
  await tester.tap(find.text('중복 확인').first);
  await tester.pump();
  await tester.tap(find.text('중복 확인').last);
  await tester.pump();
  return session;
}

void main() {
  testWidgets('가입 성공: memberId를 세션에 저장하고 /movies로 이동', (tester) async {
    final service = _FakeService()
      ..onSignUp = (_) async => const CommonResponse<SignUpResult>(
        isSuccess: true,
        code: 'OK',
        message: 'ok',
        result: SignUpResult(
          memberId: 42,
          email: 'a@b.com',
          nickname: 'tester',
        ),
      );
    final session = await _pumpAndFill(tester, service);

    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();

    expect(session.memberId, 42);
    expect(find.text('영화 목록 화면'), findsOneWidget);
    expect(service.sent!.email, ' a@b.com '); // 공백 제거는 toJson에서 한다
    expect(service.sent!.toJson()['email'], 'a@b.com');
  });

  testWidgets('가입 실패: 스낵바를 보여주고 화면과 세션은 그대로', (tester) async {
    final service = _FakeService()
      ..onSignUp = (_) async => throw DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 409,
          data: {
            'isSuccess': false,
            'code': 'DUP',
            'message': '이미 가입된 이메일입니다.',
          },
        ),
      );
    final session = await _pumpAndFill(tester, service);

    await tester.tap(find.text('가입하기'));
    await tester.pump();
    await tester.pump();

    expect(find.text('이미 가입된 이메일입니다.'), findsOneWidget); // 스낵바
    expect(session.memberId, isNull);
    expect(find.text('영화 목록 화면'), findsNothing);
  });

  testWidgets('비밀번호가 8자 미만이면 요청을 보내지 않는다', (tester) async {
    final service = _FakeService()
      ..onSignUp = (_) async => throw StateError('x');
    await _pumpAndFill(tester, service);
    await tester.enterText(find.widgetWithText(TextFormField, '비밀번호'), '1234');
    await tester.pump();

    await tester.tap(find.text('가입하기'));
    await tester.pump();

    expect(find.text('비밀번호는 8자 이상 입력해 주세요.'), findsOneWidget);
    expect(service.sent, isNull);
  });
}
