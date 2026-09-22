import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 화면마다 새로 만들지 않고 재사용하는 공용 AppBar.
///
/// Scaffold.appBar 자리에 들어가려면 PreferredSizeWidget을 구현해야 해서,
/// 일반 StatelessWidget이 아니라 이 타입을 implements 한다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      // AppBarTheme(app_theme.dart)에서 backgroundColor/elevation을 이미
      // 정의해뒀기 때문에 여기서는 제목 스타일만 신경 쓰면 된다.
      centerTitle: false,
      automaticallyImplyLeading: false,
      // leading 슬롯(고정 56dp 너비, 아이콘 버튼용)을 쓰면 로고가 비좁게
      // 잘려 보여서, 대신 title 안에 로고 + 글자를 Row로 나란히 넣는다.
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/logos/movielog_logo.svg',
            width: 32,
            height: 32,
            semanticsLabel: 'MovieLog 로고',
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(color: colors.primary),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
