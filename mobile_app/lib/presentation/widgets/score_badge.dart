import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.points,
    this.compact = false,
  });

  final int points;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: compact ? 14 : 18,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$points баллов',
            style: (compact ? AppTextStyles.caption : AppTextStyles.bodySecondary)
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class PodiumAvatar extends StatelessWidget {
  const PodiumAvatar({
    super.key,
    required this.nickname,
    required this.points,
    required this.rank,
    this.avatarUrl,
  });

  final String nickname;
  final int points;
  final int rank;
  final String? avatarUrl;

  Color get _podiumColor {
    switch (rank) {
      case 1:
        return AppColors.goldPodium;
      case 2:
        return AppColors.silverPodium;
      case 3:
        return AppColors.bronzePodium;
      default:
        return AppColors.divider;
    }
  }

  double get _size => rank == 1 ? 72 : 56;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1)
          const Icon(Icons.emoji_events, color: AppColors.goldPodium, size: 28),
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _podiumColor, width: 3),
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.chipBackground,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                    style: AppTextStyles.heading3,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nickname,
          style: AppTextStyles.bodySecondary,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$points',
          style: AppTextStyles.heading3.copyWith(color: _podiumColor),
        ),
      ],
    );
  }
}