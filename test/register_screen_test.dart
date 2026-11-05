import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/screens/register_screen.dart';
import 'package:movielog/services/member_check_service.dart';
import 'package:provider/provider.dart';

class _FakeService extends MemberCheckService {
  _FakeService({this.nicknameAvailable = true}) : super(Dio());
  final bool nicknameAvailable;

  @override
  Future<bool> checkNickname(String nickname) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return nicknameAvailable;
  }

  @override
  Future<bool> checkEmail(String email) async => true;
}

Widget _app(MemberCheckService service) => Provider<MemberCheckService>.value(
  value: service,
  child: const MaterialApp(home: RegisterScreen()),
);

void main() {
  testWidgets('닉네임: 확인 전 → 통신 중 → 사용 가능', (tester) async {
    await tester.pumpWidget(_app(_FakeService()));
    await tester.enterText(find.widgetWithText(TextFormField, '닉네임'), 'test1');
    await tester.pump();

    expect(find.text('사용할 수 있는 닉네임입니다.'), findsNothing); // 확인 전

    await tester.tap(find.text('중복 확인').first);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // 통신 중

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('사용할 수 있는 닉네임입니다.'), findsOneWidget); // 사용 가능
  });

  testWidgets('닉네임: 중복이면 빨간 문구, 다시 입력하면 사라진다', (tester) async {
    await tester.pumpWidget(_app(_FakeService(nicknameAvailable: false)));
    final field = find.widgetWithText(TextFormField, '닉네임');
    await tester.enterText(field, 'test1');
    await tester.pump();
    await tester.tap(find.text('중복 확인').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget); // 중복

    await tester.enterText(field, 'test12');
    await tester.pump();
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsNothing); // idle로 복귀
  });

  testWidgets('가입하기 버튼은 닉네임·이메일 확인 전에는 비활성', (tester) async {
    await tester.pumpWidget(_app(_FakeService()));
    ElevatedButton submit() => tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('가입하기'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(submit().onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, '닉네임'), 'test1');
    await tester.enterText(
      find.widgetWithText(TextFormField, '이메일'),
      'a@b.com',
    );
    await tester.pump();
    await tester.tap(find.text('중복 확인').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('중복 확인').last);
    await tester.pump(const Duration(milliseconds: 100));
    expect(submit().onPressed, isNotNull);
  });
}
