import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/widgets/rating_dialog.dart';

Future<bool?> _open(
  WidgetTester tester,
  Future<void> Function(int, String?) onSubmit,
) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (_) => RatingDialog(onSubmit: onSubmit),
              );
            },
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
  return result;
}

ElevatedButton _confirm(WidgetTester tester) => tester.widget<ElevatedButton>(
  find.ancestor(of: find.text('확인'), matching: find.byType(ElevatedButton)),
);

void main() {
  testWidgets('별을 고르기 전에는 확인 버튼이 비활성이다', (tester) async {
    await _open(tester, (_, _) async {});
    expect(_confirm(tester).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.star).at(3));
    await tester.pump();
    expect(_confirm(tester).onPressed, isNotNull);
  });

  testWidgets('확인을 누르면 점수와 코멘트를 넘기고 닫힌다', (tester) async {
    int? gotScore;
    String? gotComment;
    await _open(tester, (score, comment) async {
      gotScore = score;
      gotComment = comment;
    });

    await tester.tap(find.byIcon(Icons.star).at(3));
    await tester.enterText(find.byType(TextField), '  재밌어요  ');
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(gotScore, 4);
    expect(gotComment, '재밌어요'); // 앞뒤 공백 제거
    expect(find.byType(RatingDialog), findsNothing); // 닫힘
  });

  testWidgets('코멘트가 비어 있으면 null로 넘긴다', (tester) async {
    String? gotComment = 'x';
    await _open(tester, (score, comment) async => gotComment = comment);

    await tester.tap(find.byIcon(Icons.star).at(2));
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(gotComment, isNull);
  });

  testWidgets('저장에 실패하면 Dialog가 남고 오류 문구가 보인다', (tester) async {
    await _open(tester, (_, _) async => throw Exception('fail'));

    await tester.tap(find.byIcon(Icons.star).at(2));
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.byType(RatingDialog), findsOneWidget);
    expect(find.text('저장하지 못했습니다. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(_confirm(tester).onPressed, isNotNull); // 다시 시도 가능
  });

  testWidgets('저장 중에는 취소가 막히고 로딩이 보인다', (tester) async {
    await _open(tester, (_, _) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.tap(find.byIcon(Icons.star).at(2));
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final cancel = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text('취소'), matching: find.byType(ElevatedButton)),
    );
    expect(cancel.onPressed, isNull);

    await tester.pumpAndSettle();
  });
}
