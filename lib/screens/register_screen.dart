import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/validators/password_validator.dart';
import '../models/create_member_request.dart';
import '../services/sign_up_service.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

/// 회원가입 화면. 가입 요청 중에는 뒤로가기를 막는다.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (context) => SignUpViewModel(context.read<SignUpService>()),
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: viewModel.submitStatus != SubmitStatus.submitting,
            child: Scaffold(
              appBar: AppBar(title: const Text('회원가입')),
              body: child,
            ),
          );
        },
        child: const _SignUpForm(),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
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
    return SafeArea(
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
              Consumer<SignUpViewModel>(
                builder: (context, viewModel, child) {
                  return TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      errorText: viewModel.passwordErrorText,
                    ),
                    obscureText: true,
                    validator: (value) => validatePasswordFormat(value),
                    onChanged: (_) => viewModel.onPasswordChanged(),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
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

  Future<void> _onSubmitPressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final viewModel = context.read<SignUpViewModel>();
    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!context.mounted) return;
    if (viewModel.submitStatus == SubmitStatus.success &&
        viewModel.createdMemberId != null) {
      // 가입에 성공하면 이 회원 ID를 앱 전체(평점 저장·내 평점 목록)에서 쓴다.
      context.read<LearningMemberSession>().setMemberId(
        viewModel.createdMemberId!,
      );
      context.go('/movies');
      return;
    }
    if (viewModel.snackbarMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(viewModel.snackbarMessage!)));
    }
  }

  Widget _buildSubmitButton() {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          isLoading: viewModel.submitStatus == SubmitStatus.submitting,
          // 닉네임·이메일 중복 확인이 끝나야 눌린다.
          onPressed: viewModel.canSubmit
              ? () => _onSubmitPressed(context)
              : null,
        );
      },
    );
  }
}
