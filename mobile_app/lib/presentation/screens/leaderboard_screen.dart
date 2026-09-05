import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/leaderboard/leaderboard_bloc.dart';
import '../../logic/map/map_models.dart';
import '../widgets/score_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardBloc>().add(const LeaderboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Региональный рейтинг')),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading || state is LeaderboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeaderboardError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.bodySecondary),
            );
          }

          final loaded = state as LeaderboardLoaded;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (loaded.topThree.isNotEmpty) _buildPodium(loaded.topThree),
                    const SizedBox(height: 24),
                    ...loaded.restOfList.map((entry) => _RankTile(entry: entry)),
                  ],
                ),
              ),
              _buildUserRankBar(context, loaded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryModel> topThree) {
    final ordered = <LeaderboardEntryModel?>[null, null, null];
    for (final entry in topThree) {
      if (entry.rank <= 3) ordered[entry.rank - 1] = entry;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (ordered[1] != null)
          PodiumAvatar(
            nickname: ordered[1]!.user.nickname,
            points: ordered[1]!.user.ratingPoints,
            rank: 2,
            avatarUrl: ordered[1]!.user.avatarUrl,
          ),
        if (ordered[0] != null)
          PodiumAvatar(
            nickname: ordered[0]!.user.nickname,
            points: ordered[0]!.user.ratingPoints,
            rank: 1,
            avatarUrl: ordered[0]!.user.avatarUrl,
          ),
        if (ordered[2] != null)
          PodiumAvatar(
            nickname: ordered[2]!.user.nickname,
            points: ordered[2]!.user.ratingPoints,
            rank: 3,
            avatarUrl: ordered[2]!.user.avatarUrl,
          ),
      ],
    );
  }

  Widget _buildUserRankBar(BuildContext context, LeaderboardLoaded loaded) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();

        final currentUserId = authState.user.id;
        final myEntryIndex = loaded.entries.indexWhere(
          (e) => e.user.id == currentUserId,
        );

        if (myEntryIndex == -1) return const SizedBox.shrink();

        final myEntry = loaded.entries[myEntryIndex];
        final pointsToNext = myEntry.pointsToNextRank;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Text(
                'Вы (${myEntry.user.nickname}) — ${myEntry.rank} место',
                style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (pointsToNext != null && pointsToNext > 0)
                Text(
                  'До топ-${myEntry.rank - 1} ещё $pointsToNext баллов',
                  style: AppTextStyles.bodySecondary,
                )
              else
                ScoreBadge(points: myEntry.user.ratingPoints, compact: true),
            ],
          ),
        );
      },
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry});

  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(
          '${entry.rank}',
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
      ),
      title: Text(entry.user.nickname, style: AppTextStyles.bodyRegular),
      subtitle: Text(
        'Найдено: ${entry.user.spotsFoundCount} • Убрано: ${entry.user.spotsCleanedCount}',
        style: AppTextStyles.caption,
      ),
      trailing: Text(
        '${entry.user.ratingPoints}',
        style: AppTextStyles.heading3.copyWith(color: AppColors.primaryGreenEnd),
      ),
    );
  }
}