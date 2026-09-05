import '../map/map_models.dart';

class SpotSearchResultModel {
  final SpotModel spot;
  final int ratingAwarded;
  final bool isDuplicate;
  final double? duplicateDistanceM;

  SpotSearchResultModel({
    required this.spot,
    required this.ratingAwarded,
    required this.isDuplicate,
    this.duplicateDistanceM,
  });

  factory SpotSearchResultModel.fromJson(Map<String, dynamic> json) {
    return SpotSearchResultModel(
      spot: SpotModel.fromJson(json['spot'] as Map<String, dynamic>),
      ratingAwarded: (json['rating_awarded'] as num).toInt(),
      isDuplicate: json['is_duplicate'] as bool,
      duplicateDistanceM: json['duplicate_distance_m'] != null
          ? (json['duplicate_distance_m'] as num).toDouble()
          : null,
    );
  }
}

class SpotCleanupResultModel {
  final SpotModel spot;
  final int ratingAwarded;
  final int contaminationDelta;

  SpotCleanupResultModel({
    required this.spot,
    required this.ratingAwarded,
    required this.contaminationDelta,
  });

  factory SpotCleanupResultModel.fromJson(Map<String, dynamic> json) {
    return SpotCleanupResultModel(
      spot: SpotModel.fromJson(json['spot'] as Map<String, dynamic>),
      ratingAwarded: (json['rating_awarded'] as num).toInt(),
      contaminationDelta: (json['contamination_delta'] as num).toInt(),
    );
  }
}