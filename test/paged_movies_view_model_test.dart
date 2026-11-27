import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/models/tmdb_movie_page.dart';
import 'package:movielog/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';

TmdbMovieDto _movie(int id) => TmdbMovieDto(
  id: id,
  title: '영화 $id',
  overview: '',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2026-01-01',
  genreIds: const [],
  voteAverage: 7,
  popularity: 1,
);

TmdbMoviePageDto _page(int page, List<int> ids, {int totalPages = 3}) =>
    TmdbMoviePageDto(
      page: page,
      results: ids.map(_movie).toList(),
      totalPages: totalPages,
      totalResults: totalPages * 20,
    );

class _FakeTmdb extends TmdbMovieService {
  _FakeTmdb() : super(Dio());

  final calls = <({int page, int? genreId, String? query})>[];
  final gates = <int?, Completer<void>>{}; // 장르별로 응답을 늦추는 문
  bool failNext = false;

  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) async {
    calls.add((page: page, genreId: genreId, query: null));
    await gates[genreId]?.future;
    if (failNext) {
      failNext = false;
      throw Exception('network');
    }
    return _page(page, [genreId ?? 0, page * 100 + (genreId ?? 0)]);
  }

  @override
  Future<TmdbMoviePageDto> searchMovies({
    required int page,
    required String query,
  }) async {
    calls.add((page: page, genreId: null, query: query));
    return _page(page, [900 + page], totalPages: 1);
  }
}

void main() {
  late _FakeTmdb tmdb;
  late PagedMoviesViewModel vm;

  setUp(() {
    tmdb = _FakeTmdb();
    vm = PagedMoviesViewModel(tmdbApi: tmdb);
  });

  test('첫 page만 불러오고 더 보기로 다음 page를 아래에 붙인다', () async {
    await vm.loadInitial();
    expect(vm.phase, LoadPhase.ready);
    expect(tmdb.calls.length, 1);
    final firstCount = vm.movies.length;

    await vm.loadNextPage();
    expect(tmdb.calls.last.page, 2);
    expect(vm.movies.length, greaterThan(firstCount));
  });

  test('다음 page 요청이 실패하면 같은 page를 다시 요청할 수 있다', () async {
    await vm.loadInitial();
    tmdb.failNext = true;
    await vm.loadNextPage();
    expect(vm.loadMoreError, isNotNull);
    expect(vm.nextPage, 2);

    await vm.loadNextPage();
    expect(tmdb.calls.last.page, 2); // 같은 page를 다시 요청
    expect(vm.loadMoreError, isNull);
  });

  test('장르를 바꾸면 이전 목록을 비우고 첫 page부터 불러온다', () async {
    await vm.loadInitial();
    await vm.loadNextPage();
    await vm.loadInitial(genreId: 28);

    expect(tmdb.calls.last.page, 1);
    expect(tmdb.calls.last.genreId, 28);
    expect(vm.nextPage, 2);
  });

  test('이전 장르의 느린 응답이 새 목록에 섞이지 않는다', () async {
    tmdb.gates[28] = Completer<void>(); // 28번 장르 응답을 늦춘다
    final slow = vm.loadInitial(genreId: 28);
    await Future<void>.delayed(Duration.zero);
    await vm.loadInitial(genreId: 35); // 새 장르가 먼저 끝난다

    final expectedIds = vm.movies.map((m) => m.id).toList();
    tmdb.gates[28]!.complete(); // 이제 늦은 응답이 도착
    await slow;

    expect(vm.movies.map((m) => m.id).toList(), expectedIds);
    expect(vm.movies.any((m) => m.id == 28), isFalse);
  });

  test('검색어가 있으면 검색 API를 쓰고 결과를 더 보기로 이어 간다', () async {
    await vm.loadInitial(query: '인터스텔라');
    expect(tmdb.calls.first.query, '인터스텔라');
    expect(vm.phase, LoadPhase.ready);
  });
}
