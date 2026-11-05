import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/services/member_check_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final MemberCheckService _service;

  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? _duplicatedNickname;
  String _currentNickname = '';
  int _requestVersion = 0;
  bool _disposed = false;

  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText;
  String? _duplicatedEmail;
  String _currentEmail = '';
  int _emailRequestVersion = 0; // 닉네임 요청과 버전을 섞지 않는다.

  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  /// 닉네임과 이메일 모두 "사용 가능"으로 확인돼야 가입할 수 있다.
  bool get canSubmit =>
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available;

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  void onNicknameChanged(String value) {
    final trimmed = value.trim();
    _currentNickname = trimmed;
    _requestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedNickname != null && trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> checkNickname(String value) async {
    final requested = value.trim();
    if (requested.isEmpty ||
        requested != _currentNickname ||
        !canCheckNickname) {
      return;
    }

    final version = ++_requestVersion;
    nicknameCheckStatus = CheckStatus.checking;
    nicknameErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkNickname(requested);
      if (_disposed ||
          version != _requestVersion ||
          _currentNickname != requested) {
        return;
      }
      nicknameCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested;
    } on DioException {
      if (_disposed ||
          version != _requestVersion ||
          _currentNickname != requested) {
        return;
      }
      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  void onEmailChanged(String value) {
    final trimmed = value.trim();
    _currentEmail = trimmed;
    _emailRequestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedEmail != null && trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> checkEmail(String value) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != _currentEmail || !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkEmail(requested);
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }
      emailCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      // 정상적인 "사용 불가" 응답이다. 통신 실패 문구와 구분한다.
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }
      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _emailRequestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
