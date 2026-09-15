import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    return Scaffold(
      appBar: const AppTopBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding: 화면 "안쪽" 여백 — 본문 전체와 화면 가장자리 사이 간격.
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                name: '무비러버',
                bio: '매주 주말엔 영화관으로 출근하는 프로 관람객. '
                    '좋은 영화를 보고 기록하는 것을 좋아합니다.',
                onEditPressed: () {},
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
