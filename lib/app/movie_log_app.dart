import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/movielog_client.dart';
import '../core/network/tmdb_client.dart';
import '../router/app_router.dart';
import '../services/tmdb_movie_service.dart';
import '../theme/app_theme.dart';

// 여러 Route가 공유하는 객체는 MaterialApp.router 바깥(최상단)에 등록한다.
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 자체 API용 Client. TMDB Client와 별개 인스턴스다.
        Provider<MovieLogClient>(
          create: (_) => MovieLogClient(createMovieLogDio()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
