import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/common_response.dart';
import 'package:movielog/models/create_member_request.dart';
import 'package:movielog/models/sign_up_models.dart';
import 'package:movielog/screens/register_screen.dart';
import 'package:movielog/services/sign_up_service.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

class _SlowService extends SignUpService {
  _SlowService() : super(Dio());

  @override
  Future<bool> checkNickname(String nickname) async => true;

  @override
  Future<bool> checkEmail(String email) async => true;

  @override
  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    throw DioException(requestOptions: RequestOptions());
  }
}

void main() {
  testWidgets('가입 요청 중에는 뒤로가기가 막히고, 끝나면 다시 된다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<SignUpService>.value(value: _SlowService()),
          ChangeNotifierProvider<LearningMemberSession>(
            create: (_) => LearningMemberSession(),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '닉네임'), 'tester');
    await tester.enterText(
      find.widgetWithText(TextFormField, '이메일'),
      'a@b.com',
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

    await tester.tap(find.text('가입하기'));
    await tester.pump(); // 제출 중

    await tester.binding.handlePopRoute(); // 시스템 뒤로가기
    await tester.pump();
    expect(find.byType(RegisterScreen), findsOneWidget); // 막힘

    await tester.pump(const Duration(milliseconds: 300)); // 실패로 끝남
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsNothing); // 이제 닫힘
  });
}
