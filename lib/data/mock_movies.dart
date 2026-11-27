import '../models/movie.dart';

const List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: '별빛 아래 우리',
    genres: ['로맨스', '드라마'],
    year: 2024,
    runtimeMinutes: 124,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    ratingCount: 1245,
    synopsis:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. '
        '매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.',
  ),
  Movie(
    id: '2',
    title: '우주의 끝에서',
    genres: ['SF'],
    year: 2024,
    runtimeMinutes: 118,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    ratingCount: 892,
    synopsis:
        '통신이 끊긴 심우주 탐사선에서 홀로 깨어난 항해사가 사라진 동료들의 흔적을 쫓는다. '
        '광활한 우주의 침묵 속에서 그는 진실과 마주하게 된다.',
  ),
  Movie(
    id: '3',
    title: '기억의 숲',
    genres: ['애니메이션'],
    year: 2022,
    runtimeMinutes: 99,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    ratingCount: 530,
    synopsis: '숲 속에서 속삭이는 목소리를 따라간 소녀가 잊혀진 기억들을 하나씩 되찾아가는 신비로운 모험을 그린다.',
  ),
  Movie(
    id: '4',
    title: '밤의 그림자',
    genres: ['스릴러'],
    year: 2024,
    runtimeMinutes: 110,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    ratingCount: 410,
    synopsis:
        '연쇄 실종 사건을 쫓던 형사가 사건의 배후에 자신과 얽힌 오래된 비밀이 있음을 알게 되며 벌어지는 긴장감 넘치는 추적극.',
  ),
  Movie(
    id: '5',
    title: '봄날의 커피',
    genres: ['로맨스'],
    year: 2021,
    runtimeMinutes: 105,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
    ratingCount: 230,
    synopsis:
        '작은 골목 카페를 운영하는 주인과 매일 같은 시간에 들르는 단골손님 사이에 조금씩 싹트는 잔잔하고 다정한 사랑 이야기.',
  ),
  Movie(
    id: '6',
    title: '어비스 워커',
    genres: ['SF', '액션'],
    year: 2023,
    runtimeMinutes: 132,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.6,
    ratingCount: 980,
    synopsis: '도심 한복판에서 벌어진 의문의 폭발 사고, 그 중심에 선 요원이 도시를 지키기 위해 거대한 음모에 맞선다.',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}

/// 영화 목록 화면의 장르 필터 Chip에 쓰이는 전체 장르 목록.
/// '전체'를 맨 앞에 두고, mock 데이터에 등장하는 장르를 중복 없이 이어붙인다.
List<String> get allGenres {
  final genres = <String>{};
  for (final movie in mockMovies) {
    genres.addAll(movie.genres);
  }
  return ['전체', ...genres];
}

/// 홈 화면의 "인기 영화" 목록. 평점이 높은 순으로 정렬한다.
List<Movie> get popularMovies {
  final sorted = [...mockMovies];
  sorted.sort((a, b) => b.rating.compareTo(a.rating));
  return sorted;
}
