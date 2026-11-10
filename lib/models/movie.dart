class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genres,
    required this.year,
    required this.runtimeMinutes,
    required this.posterAsset,
    required this.rating,
    required this.ratingCount,
    required this.synopsis,
  });

  final String id;
  final String title;
  final List<String> genres;
  final int year;
  final int runtimeMinutes;
  final String posterAsset;
  final double rating;
  final int ratingCount;
  final String synopsis;
}
