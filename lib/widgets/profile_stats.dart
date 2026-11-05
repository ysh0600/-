import 'package:flutter/material.dart';

import 'stat_item.dart';

/// 통계 항목 목록을 받아 StatItem을 가로로 나열하는 Row.
/// StatItem 자체는 건드리지 않고 "재사용"만 한다.
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.stats});

  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++)
          Expanded(
            child: Container(
              // Margin: 카드 "바깥쪽" 여백 (카드와 카드 사이 간격).
              // 맨 앞/맨 뒤 카드는 화면 padding과 겹치지 않게 절반만 준다.
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == stats.length - 1 ? 0 : 6,
              ),
              child: stats[i],
            ),
          ),
      ],
    );
  }
}
