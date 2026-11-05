import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/start_screen.dart';
import '../services/rating_api_service.dart';
import '../services/tmdb_movie_service.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/nav_bar.dart';

class AppRouter {
  AppRouter._();

  // 하단 탭과 1:1로 대응하는 경로들. 현재 위치가 이 중 어디에 속하는지로
  // NavigationBar의 selectedIndex를 계산한다.
  static const _tabPaths = ['/home', '/movies', '/my'];

  // root Navigator를 가리키는 키. 하단 NavigationBar를 가리는 화면에서 쓴다.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey, // GoRouter 전체가 쓸 root Navigator
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final index = _tabPaths.indexWhere(
            (path) => state.uri.toString().startsWith(path),
          );
          return MainScreen(
            currentIndex: index == -1 ? 0 : index,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieHomeViewModel>(
                  create: (context) =>
                      MovieHomeViewModel(context.read<TmdbMovieService>())
                        ..loadPopular(),
                  child: const HomeScreen(),
                ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieListViewModel>(
                  create: (context) =>
                      MovieListViewModel(context.read<TmdbMovieService>())
                        ..loadInitial(),
                  child: const MovieListScreen(),
                ),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'ratings', // 최종 경로: /my/ratings
                // root Navigator 위에 표시해 하단 NavigationBar를 가린다.
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    ChangeNotifierProvider<MyRatingsViewModel>(
                      create: (context) => MyRatingsViewModel(
                        context.read<RatingApiService>(),
                        context.read<TmdbMovieService>(),
                        sampleMemberId, // 6주차는 학습용 ID 1입니다.
                      )..load(),
                      child: const MyRatingsScreen(),
                    ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) =>
            ChangeNotifierProvider<MovieDetailViewModel>(
              create: (context) => MovieDetailViewModel(
                context.read<TmdbMovieService>(),
                int.parse(state.pathParameters['movieId']!),
              )..load(),
              child: const MovieDetailScreen(),
            ),
      ),
    ],
  );
}
