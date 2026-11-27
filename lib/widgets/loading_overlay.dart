import 'package:flutter/material.dart';

/// 요청 중에 화면 전체를 어둡게 덮고 터치를 막는 오버레이.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ModalBarrier(dismissible: false, color: Colors.black45),
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}
