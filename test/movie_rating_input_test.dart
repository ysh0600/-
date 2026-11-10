import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/widgets/movie_rating_input.dart';

void main() {
  testWidgets('별을 누르면 해당 점수로 onChanged가 호출된다', (tester) async {
    double? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieRatingInput(rating: 0, onChanged: (v) => picked = v),
        ),
      ),
    );

    final stars = find.byIcon(Icons.star);
    expect(stars, findsNWidgets(5));

    await tester.tap(stars.at(3)); // 네 번째 별
    expect(picked, 4.0);
  });

  testWidgets('enabled가 false면 눌러도 반응하지 않는다', (tester) async {
    double? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieRatingInput(
            rating: 2,
            enabled: false,
            onChanged: (v) => picked = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star).at(4));
    expect(picked, isNull);
  });
}
