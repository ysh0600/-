import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/core/session/auth_bridge.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/services/favorite_api_service.dart';
import 'package:provider/provider.dart';

import '../core/network/movie_log_client.dart';
import '../core/network/tmdb_client.dart';
import '../core/storage/token_storage.dart';
import '../models/login_models.dart';
import '../router/app_router.dart';
import '../services/member_api_service.dart';
import '../services/rating_api_service.dart';
import '../services/sign_up_service.dart';
import '../services/tmdb_movie_service.dart';
import '../theme/app_theme.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/learning_member_session.dart';

// 여러 Route가 공유하는 객체는 MaterialApp.router 바깥(최상단)에 등록한다.
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());
    final publicClient = createMovieLogClient(); // Interceptor 없음
    final authClient = createAuthMovieLogClient(tokenStorage); // Interceptor 등록

    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 공개 Client
        Provider<AuthApiService>(create: (_) => AuthApiService(publicClient)),
        Provider<SignUpService>(create: (_) => SignUpService(publicClient)),
        // 보호 Client (RatingApiService는 공개 조회용 publicClient도 함께 받음)
        Provider<MemberApiService>(create: (_) => MemberApiService(authClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(publicClient, authClient),
        ),
        // Service를 주입받는 ViewModel.
        // AuthSessionBridge가 이 ViewModel을 읽으므로 반드시 그보다 위(앞)에 둔다.
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
        // 기존 MultiProvider의 providers 목록에 추가합니다.
        Provider<AuthSessionBridge>(
          create: (context) {
            final auth = context.read<AuthViewModel>();
            return AuthSessionBridge(
              authSignals: auth,
              sessionVersion: () => auth.sessionVersion,
              verifiedEmail: () => auth.status == AuthStatus.signedIn
                  ? auth.member?.email
                  : null,
            );
          },
          dispose: (_, bridge) => bridge.dispose(),
        ),
        Provider<SessionGuard>(
          create: (context) => context.read<AuthSessionBridge>().guard,
        ),
        // 기존 MultiProvider의 providers 목록에 추가합니다.
        // authClient는 8주차에서 만든 보호용 Dio입니다. 새로 만들지 않고 기존 인스턴스를 사용합니다.
        Provider<FavoriteApiService>(
          create: (_) => FavoriteApiService(authClient),
        ),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) authViewModel.restoreSession();
    }); // 첫 build 이후 세션 복원을 시작합니다.
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
