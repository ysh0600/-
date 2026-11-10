import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _validColor = Color(0xFF34A853);

/// 라벨 텍스트 + TextFormField 한 쌍을 표현하는 위젯.
///
/// 닉네임/이메일/비밀번호 입력창이 모두 "라벨 - 간격 - 입력창" 구조를
/// 반복하기 때문에, ProfileScreen에서 StatItem을 재사용하는 것과 같은
/// 방식으로 SignupScreen에서 세 번 재사용한다.
///
/// 값이 비어있지 않을 때는 [validator] 결과에 따라 테두리 배경과
/// 체크/경고 아이콘으로 현재 상태(정상/오류)를 함께 보여준다.
class LabeledFormField extends StatelessWidget {
  const LabeledFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.focusNode,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    // 빈 입력값은 아직 아무것도 판단할 수 없으니 중립 상태로 둔다.
    final value = controller.text;
    final hasError = value.isNotEmpty && validator?.call(value) != null;
    final isValid = value.isNotEmpty && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: hasError,
            fillColor: colors.errorContainer,
            suffixIcon: switch ((hasError, isValid)) {
              (true, _) => SvgPicture.asset(
                'assets/icons/error.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(colors.error, BlendMode.srcIn),
              ),
              (_, true) => SvgPicture.asset(
                'assets/icons/check_circle.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(_validColor, BlendMode.srcIn),
              ),
              _ => null,
            },
          ),
        ),
      ],
    );
  }
}
