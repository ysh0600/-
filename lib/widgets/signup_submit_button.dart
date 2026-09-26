import 'package:flutter/material.dart';

/// 회원가입 제출 버튼.
///
/// [enabled]가 false면 onPressed에 null을 넘겨 Material 버튼 자체의
/// 비활성 스타일(흐린 배경)을 그대로 활용한다.
class SignupSubmitButton extends StatelessWidget {
  const SignupSubmitButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: const Text('가입하기'),
    );
  }
}
