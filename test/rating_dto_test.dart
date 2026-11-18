import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/rating_dto.dart';

void main() {
  test('RatingDto.fromJson은 comment가 null이어도 변환한다', () {
    final rating = RatingDto.fromJson({
      'ratingId': 7,
      'movieId': 969681,
      'score': 5,
      'comment': null,
      'createdAt': '2026-11-04T10:30:00',
    });

    expect(rating.ratingId, 7);
    expect(rating.movieId, 969681);
    expect(rating.score, 5);
    expect(rating.comment, isNull);
    expect(rating.createdAt, DateTime(2026, 11, 4, 10, 30));
  });

  test('RatingDto.fromJson은 comment가 있으면 그대로 담는다', () {
    final rating = RatingDto.fromJson({
      'ratingId': 8,
      'movieId': 1,
      'score': 3,
      'comment': '재밌어요',
      'createdAt': '2026-11-04T10:30:00',
    });

    expect(rating.comment, '재밌어요');
  });
}
