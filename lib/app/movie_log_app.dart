import 'package:flutter/material.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/services/sign_up_service.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

import '../core/network/tmdb_client.dart';
import '../router/app_router.dart';
import '../services/rating_api_service.dart';
import '../services/tmdb_movie_service.dart';
import '../theme/app_theme.dart';

// 여러 Route가 공유하는 객체는 MaterialApp.router 바깥(최상단)에 등록한다.
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient();
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
        // lib/app/movie_log_app.dart의 MultiProvider.providers에 추가합니다.
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),
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
