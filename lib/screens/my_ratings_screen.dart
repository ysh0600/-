import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rating_dto.dart';
import '../models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/movie_loading_view.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

/// 내가 등록한 평점 목록. root Navigator 위에 올라오는 화면이라
/// 하단 NavigationBar 없이 중앙 AppBar와 BackButton만 둔다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRatingsViewModel>();

    final scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: const Text('내가 등록한 평점'),
      ),
      body: SafeArea(
        child: switch (viewModel.status) {
          MyRatingsLoadStatus.idle ||
          MyRatingsLoadStatus.loading => const MovieLoadingView(),
          MyRatingsLoadStatus.error => _MessageView(
            icon: Icons.error_outline,
            text:
                viewModel.refreshWarning ??
                viewModel.message ??
                '평점을 불러오지 못했습니다.',
            onRetry: () {
              context.read<MyRatingsViewModel>().load();
            },
          ),
          MyRatingsLoadStatus.empty => const _MessageView(
            icon: Icons.star_border,
            text: '등록한 평점이 없어요',
          ),
          MyRatingsLoadStatus.success => _RatingList(
            ratings: viewModel.ratings,
            message: viewModel.message,
            selectedIds: viewModel.selectedRatingIds,
            isDeleting: viewModel.isDeletingSelected,
          ),
        },
      ),
    );

    // 선택 삭제 중에는 화면을 덮고, 뒤로가기도 막는다.
    return PopScope(
      canPop: !viewModel.isDeletingSelected,
      child: LoadingOverlay(
        isLoading: viewModel.isDeletingSelected,
        child: scaffold,
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({
    required this.ratings,
    required this.selectedIds,
    required this.isDeleting,
    this.message,
  });

  final List<RatingWithMovie> ratings;
  final Set<int> selectedIds;
  final bool isDeleting;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(message!, style: textTheme.bodySmall),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = ratings[index];
              final rating = item.rating;
              final movie = item.movie;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 2, color: const Color(0xFFD9D3E2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: selectedIds.contains(rating.ratingId),
                      onChanged: isDeleting
                          ? null
                          : (_) => context
                                .read<MyRatingsViewModel>()
                                .toggleSelection(rating.ratingId),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // 영화 정보가 없으면 posterPath가 null이라 placeholder가 나온다.
                      child: TmdbPosterImage(
                        posterPath: movie?.posterPath,
                        width: 56,
                        height: 84,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie?.title ?? '영화 #${rating.movieId}',
                            style: textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '별점 ${rating.score} / 5',
                            style: textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          if (rating.comment != null &&
                              rating.comment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              rating.comment!,
                              style: textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(rating.createdAt),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _CardActionButton(
                          label: '수정',
                          foreground: AppColors.primary,
                          background: const Color(0xFFEFE9F7),
                          onPressed: isDeleting
                              ? null
                              : () => onEditPressed(context, rating),
                        ),
                        const SizedBox(height: 8),
                        _CardActionButton(
                          label: '삭제',
                          foreground: const Color(0xFFA32D2D),
                          background: const Color(0xFFFBEEEC),
                          onPressed: isDeleting
                              ? null
                              : () => onDeletePressed(context, rating),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: MovieLogButton(
              label: '선택한 ${selectedIds.length}개 삭제',
              width: double.infinity,
              isLoading: isDeleting,
              onPressed: isDeleting
                  ? null
                  : () => onDeleteSelectedPressed(context),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.foreground,
    required this.background,
    required this.onPressed,
  });

  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => RatingDialog(
      initialScore: rating.score,
      initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작합니다.
      onSubmit: (score, comment) =>
          context.read<MyRatingsViewModel>().updateRating(
            ratingId: rating.ratingId,
            score: score,
            comment: comment,
          ),
    ),
  );

  if (!context.mounted || saved != true) return;
}

Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () =>
          context.read<MyRatingsViewModel>().deleteRating(rating.ratingId),
    ),
  );
  // confirmed는 실제로 삭제까지 마쳤을 때만 true입니다.
  if (!context.mounted || confirmed != true) return;
}

Future<void> onDeleteSelectedPressed(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('선택한 평점을 삭제할까요?'),
      content: const Text('삭제한 평점은 복구할 수 없습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
  // Dialog는 바로 닫히고, 삭제 요청은 닫힌 뒤 화면에서 시작합니다.
  if (confirmed != true || !context.mounted) return;

  await context.read<MyRatingsViewModel>().deleteSelectedRatings();
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }
}
