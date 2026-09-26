import 'package:flutter/material.dart';

/// 상세 화면의 공유 버튼을 누르면 올라오는 공유 옵션 BottomSheet.
/// 실제 공유 기능은 없고, 선택하면 Snackbar로 결과만 보여주는 Mock 동작이다.
class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key, required this.movieTitle});

  final String movieTitle;

  static Future<void> show(BuildContext context, String movieTitle) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareBottomSheet(movieTitle: movieTitle),
    );
  }

  void _share(BuildContext context, String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$movieTitle 공유하기', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _ShareOptionTile(
              icon: Icons.link,
              label: '링크 복사',
              onTap: () => _share(context, '링크를 복사했어요'),
            ),
            _ShareOptionTile(
              icon: Icons.chat_bubble_outline,
              label: '카카오톡으로 공유',
              onTap: () => _share(context, '카카오톡으로 공유했어요'),
            ),
            _ShareOptionTile(
              icon: Icons.camera_alt_outlined,
              label: '인스타그램 스토리에 공유',
              onTap: () => _share(context, '인스타그램 스토리에 공유했어요'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
