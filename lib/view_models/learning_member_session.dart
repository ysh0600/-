import 'package:flutter/foundation.dart';

/// 학습용으로 가입한 회원의 id를 앱 전체에서 공유한다.
/// 회원가입 성공 시 SignUpViewModel.createdMemberId를 여기에 저장한다.
class LearningMemberSession extends ChangeNotifier {
  int? memberId;

  void setMemberId(int id) {
    memberId = id;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    notifyListeners();
  }
}
