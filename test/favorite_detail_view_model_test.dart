import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';

import 'test_favorites.dart';

void main() {
  late FakeFavoriteApi api;
  late SessionGuard guard;
  late int expiredCalls;

  FavoriteDetailViewModel makeViewModel() => FavoriteDetailViewModel(
    movieId: 5,
    favoriteApi: api,
    sessionGuard: guard,
    accountId: 'a@b.c',
    onSessionExpired: () async => expiredCalls++,
  );

  setUp(() {
    api = FakeFavoriteApi();
    guard = SessionGuard()..startSession('a@b.c');
    expiredCalls = 0;
  });

  test('상세 진입 시 서버의 즐겨찾기 여부를 반영한다', () async {
    api.isFavorite = true;
    final vm = makeViewModel();
    await vm.load();

    expect(vm.isFavorite, isTrue);
    expect(vm.hasLoadedStatus, isTrue);
  });

  test('등록에 성공하면 북마크가 켜진다', () async {
    final vm = makeViewModel();
    await vm.load();
    await vm.toggle();

    expect(vm.isFavorite, isTrue);
    expect(vm.errorMessage, isNull);
  });

  test('403이면 이전 아이콘을 유지하고 로그아웃하지 않는다', () async {
    final vm = makeViewModel();
    await vm.load();
    api.failWithStatus = 403;
    api.failWithCode = 'COMMON403';
    await vm.toggle();

    expect(vm.isFavorite, isFalse);
    expect(vm.errorMessage, isNotNull);
    expect(expiredCalls, 0);
  });

  test('AUTH401_2면 세션 정리를 한 번 요청한다', () async {
    final vm = makeViewModel();
    await vm.load();
    api.failWithStatus = 401;
    api.failWithCode = 'AUTH401_2';
    await vm.toggle();

    expect(expiredCalls, 1);
  });

  test('여부 조회가 AUTH401_3이면 세션 정리를 요청한다', () async {
    api.failWithStatus = 401;
    api.failWithCode = 'AUTH401_3';
    final vm = makeViewModel();
    await vm.load();

    expect(expiredCalls, 1);
  });

  test('계정이 바뀐 뒤 늦게 온 응답은 반영하지 않는다', () async {
    final vm = makeViewModel();
    await vm.load();
    api.failWithStatus = 401;
    api.failWithCode = 'AUTH401_2';
    final pending = vm.toggle();
    guard.invalidate(); // 응답이 오기 전에 로그아웃
    await pending;

    expect(expiredCalls, 0); // 이전 세션의 결과이므로 아무것도 하지 않는다
  });
}
