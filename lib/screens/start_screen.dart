import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 96,
                height: 96,
              ),
              const SizedBox(height: 24),
              Text(
                'MovieLog',
                style: textTheme.headlineSmall?.copyWith(color: colors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                '내가 본 영화를 기록하고\n취향을 발견해보세요',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
