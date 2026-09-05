import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/camera/camera_models.dart';
import '../../logic/map/map_bloc.dart';
import '../../logic/map/map_models.dart';
import 'camera_screen.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Квесты')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<MapBloc>().add(const MapSpotsRequested());
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _QuestModeCard(
              title: 'Поиск загрязнений',
              description:
                  'Сфотографируй участок побережья — ИИ определит уровень загрязнения и начислит от ${AppConstants.ratingSearchMin} до ${AppConstants.ratingSearchMax} баллов.',
              icon: Icons.search,
              color: AppColors.warningAmber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraScreen(initialMode: QuestMode.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _QuestModeCard(
              title: 'Уборка места',
              description:
                  'Выбери точку на карте, сделай фото "до" и "после" — получи от ${AppConstants.ratingCleanupMin} до ${AppConstants.ratingCleanupMax} баллов за реальный вклад.',
              icon: Icons.cleaning_services,
              color: AppColors.successGreen,
              onTap: () => _showSelectSpotHint(context),
            ),
            const SizedBox(height: 24),
            Text('Активные точки рядом', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state is MapLoading || state is MapInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final spots = state is MapLoaded
                    ? state.spots.where((s) => s.status == 'ACTIVE').toList()
                    : <SpotModel>[];

                if (spots.isEmpty) {
                  return Text(
                    'Активных точек не найдено — попробуй "Поиск загрязнений"',
                    style: AppTextStyles.bodySecondary,
                  );
                }

                return Column(
                  children: spots
                      .map((spot) => _ActiveSpotTile(
                            spot: spot,
                            onCleanupTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CameraScreen(
                                    initialMode: QuestMode.cleanup,
                                    targetSpotId: spot.id,
                                  ),
                                ),
                              );
                            },
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectSpotHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Выбери активную точку из списка ниже или на карте'),
      ),
    );
  }
}

class _QuestModeCard extends StatelessWidget {
  const _QuestModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSpotTile extends StatelessWidget {
  const _ActiveSpotTile({required this.spot, required this.onCleanupTap});

  final SpotModel spot;
  final VoidCallback onCleanupTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.dangerRed.withValues(alpha: 0.15),
          child: Text(
            '${spot.pollutionScoreBefore ?? 0}',
            style: AppTextStyles.caption.copyWith(color: AppColors.dangerRed),
          ),
        ),
        title: Text(spot.detectedMaterials?.join(', ') ?? 'Загрязнение'),
        subtitle: Text('Уровень: ${spot.pollutionScoreBefore ?? 0}/100'),
        trailing: TextButton(
          onPressed: onCleanupTap,
          child: const Text('Убрать'),
        ),
      ),
    );
  }
}