import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/map/map_models.dart';

class HeatmapLayerBuilder {
  HeatmapLayerBuilder._();

  static List<PlacemarkMapObject> buildPlacemarks({
    required List<SpotModel> spots,
    required void Function(SpotModel spot) onTap,
  }) {
    return spots.map((spot) {
      final isCleaned = SpotStatus.fromString(spot.status) == SpotStatus.cleaned;

      return PlacemarkMapObject(
        mapId: MapObjectId('spot_${spot.id}'),
        point: Point(latitude: spot.lat, longitude: spot.lon),
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              isCleaned
                  ? 'assets/icons/pin_cleaned.png'
                  : 'assets/icons/pin_active.png',
            ),
            scale: 1.0,
          ),
        ),
        onTap: (mapObject, point) => onTap(spot),
      );
    }).toList();
  }

  static List<CircleMapObject> buildHeatCircles(List<HeatmapPointModel> points) {
    return points.map((point) {
      final color = point.status == SpotStatus.cleaned.value
          ? AppColors.successGreen.withValues(alpha: 0.25)
          : AppColors.dangerRed.withValues(alpha: 0.15 + point.weight * 0.35);

      return CircleMapObject(
        mapId: MapObjectId('heat_${point.spotId}'),
        circle: Circle(
          center: Point(latitude: point.lat, longitude: point.lon),
          radius: 40 + (point.weight * 60),
        ),
        strokeWidth: 0.0,
        fillColor: color,
      );
    }).toList();
  }
}