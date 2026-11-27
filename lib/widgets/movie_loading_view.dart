import 'package:flutter/material.dart';

class MovieLoadingView extends StatelessWidget {
  const MovieLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
