import 'package:flutter/material.dart';

/// 아바타 + 닉네임 + 소개 + 프로필 수정 버튼.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.bio,
    required this.onEditPressed,
  });

  final String name;
  final String bio;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // 원형 테두리(링) 안에 Image.asset으로 로컬 비트맵을 표시한다.
        Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(4), // 사진과 링 사이 안쪽 여백
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.primaryContainer, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/profile_movielog.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(name, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onEditPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.surface,
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: textTheme.labelLarge,
          ),
          child: const Text('프로필 수정'),
        ),
      ],
    );
  }
}
