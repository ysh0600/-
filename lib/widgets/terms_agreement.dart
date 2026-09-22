import 'package:flutter/material.dart';

/// 필수 약관 동의 체크박스 + 안내 문구를 묶은 위젯.
class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        const Text('필수 약관에 동의합니다'),
      ],
    );
  }
}
