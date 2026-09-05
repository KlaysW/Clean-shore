import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/map/map_models.dart';

class SpotBottomSheet extends StatelessWidget {
  const SpotBottomSheet({
    super.key,
    required this.spot,
    required this.onCleanupPressed,
    this.distanceMeters,
  });

  final SpotModel spot;
  final VoidCallback onCleanupPressed;
  final double? distanceMeters;

  String get _urgencyLabel {
    final score = spot.pollutionScoreBefore ?? 0;
    if (score >= 70) return 'Требует внимания';
    if (score >= 30) return 'Средний приоритет';
    return 'Низкий приоритет';
  }

  String get _distanceLabel {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()} м от вас';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} км от вас';
  }

  @override
  Widget build(BuildContext context) {
    final isCleaned = spot.status == 'CLEANED';
    final materials = spot.detectedMaterials?.join(', ') ?? 'Неизвестно';
    final score = spot.pollutionScoreBefore ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCleaned
                      ? AppColors.successGreen.withValues(alpha: 0.15)
                      : AppColors.dangerRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCleaned ? 'Очищено' : _urgencyLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: isCleaned ? AppColors.successGreen : AppColors.dangerRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (distanceMeters != null)
                Text(_distanceLabel, style: AppTextStyles.bodySecondary),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '$materials • Уровень: $score/100',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            'Спутниковый слой ДЗЗ',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),

          if (!isCleaned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCleanupPressed,
                child: const Text('Перейти к уборке'),
              ),
            ),
        ],
      ),
    );
  }
}