import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/start_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}

class AppRouter {
  AppRouter._();

  // 하단 탭과 1:1로 대응하는 경로들. 현재 위치가 이 중 어디에 속하는지로
  // NavigationBar의 selectedIndex를 계산한다.
  static const _tabPaths = ['/home', '/movies', '/my'];

  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
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
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MoviesScreen(),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) =>
            MovieDetailScreen(movieId: state.pathParameters['movieId']!),
      ),
    ],
  );
}
