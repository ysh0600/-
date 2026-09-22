import 'package:flutter/material.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/labeled_form_field.dart';
import '../widgets/signup_submit_button.dart';
import '../widgets/terms_agreement.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form.validate()/save()를 호출하려면 이 key로 FormState에 접근해야 한다.
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    // Controller/FocusNode는 직접 만든 만큼 직접 해제해야 메모리 누수가 없다.
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canSubmit =
        _nicknameController.text.trim().length >= 2 &&
        _emailController.text.contains('@') &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms;

    return Scaffold(
      appBar: const AppTopBar(title: '회원가입'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                LabeledFormField(
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요',
                  controller: _nicknameController,
                  validator: (value) {
                    final nickname = value?.trim() ?? '';
                    if (nickname.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    if (nickname.length < 2) {
                      return '닉네임은 두 글자 이상 입력해주세요';
                    }
                    return null;
                  },
                  // 닉네임 값에 반응하는 다른 위젯(가입하기 버튼 활성화)이 있으므로
                  // 입력이 바뀔 때마다 setState로 다시 그린다.
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                LabeledFormField(
                  label: '이메일',
                  hintText: '이메일 주소를 입력해주세요',
                  controller: _emailController,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return '이메일 주소를 입력해주세요';
                    }
                    if (!email.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                LabeledFormField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해주세요',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  validator: (value) {
                    final password = value?.trim() ?? '';
                    if (password.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (password.length < 8) {
                      return '비밀번호는 여덟 글자 이상 입력해주세요';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TermsAgreement(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),

                SignupSubmitButton(
                  enabled: canSubmit,
                  onPressed: () {
                    // 버튼이 활성화됐다는 것과 Form이 유효하다는 것은 별개이므로
                    // 제출 시점에 전체 필드를 다시 한번 검증한다.
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있나요?'),
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('로그인'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
