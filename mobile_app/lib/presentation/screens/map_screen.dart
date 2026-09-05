import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/map/map_bloc.dart';
import '../../logic/map/map_models.dart';
import '../widgets/bottom_sheet_spot.dart';
import '../widgets/heatmap_layer.dart';
import '../../core/constants/app_constants.dart';
import 'camera_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _mapController;
  String? _selectedFilterLabel;

  static const _filters = <String, String?>{
    'Все': null,
    'Требуют уборки': 'ACTIVE',
    'Очищено': 'CLEANED',
  };

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapSpotsRequested());
    context.read<MapBloc>().add(const MapUserLocationRequested());
  }

  void _openSpotDetails(SpotModel spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpotBottomSheet(
        spot: spot,
        onCleanupPressed: () {
          Navigator.pop(context);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чистый берег'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final points = state is AuthAuthenticated ? state.user.ratingPoints : 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text('$points баллов', style: AppTextStyles.caption),
                  backgroundColor: AppColors.chipBackground,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.entries.map((entry) {
                final isSelected = _selectedFilterLabel == entry.key ||
                    (_selectedFilterLabel == null && entry.key == 'Все');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilterLabel = entry.key);
                      context.read<MapBloc>().add(MapFilterChanged(entry.value));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocConsumer<MapBloc, MapState>(
              listener: (context, state) {
                if (state is MapError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is MapLoading || state is MapInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final spots = state is MapLoaded ? state.spots : <SpotModel>[];

                return Stack(
                  children: [
                    YandexMap(
                      onMapCreated: (controller) => _mapController = controller,
                      mapObjects: HeatmapLayerBuilder.buildPlacemarks(
                        spots: spots,
                        onTap: _openSpotDetails,
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'gps_center',
                        backgroundColor: AppColors.surface,
                        onPressed: () {
                          context.read<MapBloc>().add(const MapUserLocationRequested());
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: AppColors.primaryGreenEnd,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}