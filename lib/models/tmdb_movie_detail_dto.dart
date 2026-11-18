import 'tmdb_genre_dto.dart';

class TmdbMovieDetailDto {
  const TmdbMovieDetailDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.runtime,
    required this.genres,
    required this.voteAverage,
    required this.voteCount,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final int? runtime;
  final List<TmdbGenreDto> genres;
  final double voteAverage;
  final int voteCount;

  factory TmdbMovieDetailDto.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'] as List<dynamic>? ?? const [];

    return TmdbMovieDetailDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: rawGenres
          .map((item) => TmdbGenreDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      voteCount: (json['vote_count'] as num? ?? 0).toInt(),
    );
  }
}
