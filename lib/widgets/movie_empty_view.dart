import 'package:flutter/material.dart';

class MovieEmptyView extends StatelessWidget {
  const MovieEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 48),
          SizedBox(height: 12),
          Text('표시할 영화가 없어요'),
        ],
      ),
    );
  }
}
