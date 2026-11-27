import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/genre_chips.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final member = context.watch<AuthViewModel>().member;

    return Scaffold(
      appBar: AppTopBar(
        title: '내 프로필',
        actions: [
          TextButton(
            onPressed: () async {
              final auth = context.read<AuthViewModel>();
              final session = context.read<LearningMemberSession>();
              await auth.logout(); // 토큰과 member를 지웁니다.
              session.clear(); // 이전 계정의 memberId도 지웁니다.
            },
            child: const Text('로그아웃'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding: 화면 "안쪽" 여백 — 본문 전체와 화면 가장자리 사이 간격.
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                name: member?.nickname ?? '무비러버',
                bio: member?.email ?? '',
                // 내 정보를 불러온 뒤(member != null)에만 수정 버튼을 켠다.
                onEditPressed: member == null
                    ? null
                    : () => context.push('/my/profile/edit'),
              ),
              const SizedBox(height: 32),
              // StatItem을 세 번 재사용해서 통계 영역을 완성한다.
              ProfileStats(
                stats: const [
                  StatItem(label: '본 영화', value: '342'),
                  StatItem(label: '평점', value: '4.2'),
                  StatItem(label: '즐겨찾기', value: '58'),
                ],
              ),
              const SizedBox(height: 32),
              _MenuCard(
                title: '내가 등록한 평점',
                onTap: () => context.push('/my/ratings'),
              ),
              const SizedBox(height: 8),
              _MenuCard(
                title: '내 즐겨찾기',
                onTap: () => context.push('/my/favorites'),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/bookmark.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: '선호 장르 아이콘',
                  ),
                  const SizedBox(width: 8),
                  Text('선호하는 장르', style: textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              const GenreChips(genres: ['드라마', 'SF', '애니메이션']),
            ],
          ),
        ),
      ),
    );
  }
}

/// 테두리가 있는 둥근 메뉴 행 (내가 등록한 평점, 내 즐겨찾기).
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.primaryContainer, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
