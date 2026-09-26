// 프로필 화면이 정상적으로 렌더링되는지 확인하는 기본 스모크 테스트.

import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/main.dart';

void main() {
  testWidgets('프로필 화면에 이름과 통계가 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('프로필 수정'), findsOneWidget);
  });
}
