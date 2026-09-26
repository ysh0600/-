import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/mock_movies.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/featured_movie_banner.dart';
import '../widgets/popular_movie_tile.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final popular = popularMovies;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppTopBar(
          title: 'MovieLog',
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  colors.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              tooltip: '검색',
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘은 어떤\n영화를 볼까요?', style: textTheme.headlineSmall),
                const SizedBox(height: 20),
                FeaturedMovieBanner(movie: popular.first),
                const SizedBox(height: 32),
                SectionHeader(
                  title: '인기 영화',
                  actionLabel: '전체보기 >',
                  onActionPressed: () {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popular.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                        right: index == popular.length - 1 ? 0 : 16,
                      ),
                      child: PopularMovieTile(
                        movie: popular[index],
                        rank: index + 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
