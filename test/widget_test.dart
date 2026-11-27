// 프로필 화면이 정상적으로 렌더링되는지 확인하는 기본 스모크 테스트.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/models/login_models.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:movielog/theme/app_theme.dart';

class _MemoryStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<void> deleteAccessToken() async {}
}

void main() {
  testWidgets('프로필 화면에 이름과 통계가 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => AuthViewModel(
          AuthApiService(Dio()),
          MemberApiService(Dio()),
          _MemoryStorage(),
        ),
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('프로필 수정'), findsOneWidget);
  });
}
