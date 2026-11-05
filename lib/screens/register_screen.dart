import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/member_check_service.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/movielog_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (context) => SignUpViewModel(context.read<MemberCheckService>()),
      child: Scaffold(
        appBar: const AppTopBar(title: '회원가입'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNicknameField(),
                  const SizedBox(height: 24),
                  _buildEmailField(),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    validator: (value) {
                      if ((value ?? '').length < 8) {
                        return '비밀번호는 8자 이상 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      errorText: viewModel.nicknameErrorText,
                    ),
                    validator: (value) {
                      final nickname = value?.trim() ?? '';
                      if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
                      if (nickname.length < 2) {
                        return '닉네임은 두 글자 이상 입력해 주세요.';
                      }
                      return null;
                    },
                    onChanged: viewModel.onNicknameChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // 입력창(56)과 버튼(44) 높이 차이만큼 내려 가운데를 맞춘다.
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: MovieLogButton(
                    label: '중복 확인',
                    isLoading:
                        viewModel.nicknameCheckStatus == CheckStatus.checking,
                    onPressed: viewModel.canCheckNickname
                        ? () =>
                              viewModel.checkNickname(_nicknameController.text)
                        : null,
                  ),
                ),
              ],
            ),
            if (viewModel.nicknameCheckStatus == CheckStatus.available)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '사용할 수 있는 닉네임입니다.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmailField() {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      errorText: viewModel.emailErrorText,
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return '이메일을 입력해 주세요.';
                      if (!email.contains('@')) return '이메일 형식을 확인해 주세요.';
                      return null;
                    },
                    onChanged: viewModel.onEmailChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: MovieLogButton(
                    label: '중복 확인',
                    isLoading:
                        viewModel.emailCheckStatus == CheckStatus.checking,
                    onPressed: viewModel.canCheckEmail
                        ? () => viewModel.checkEmail(_emailController.text)
                        : null,
                  ),
                ),
              ],
            ),
            if (viewModel.emailCheckStatus == CheckStatus.available)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '사용할 수 있는 이메일입니다.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          // 닉네임·이메일 중복 확인이 끝나야 눌린다.
          onPressed: viewModel.canSubmit
              ? () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  FocusScope.of(context).unfocus();
                  context.go('/home');
                }
              : null,
        );
      },
    );
  }
}
