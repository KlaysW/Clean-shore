class SpotModel {
  final String id;
  final String? reporterId;
  final String? cleanerId;
  final double lat;
  final double lon;
  final int? pollutionScoreBefore;
  final int? pollutionScoreAfter;
  final List<String>? detectedMaterials;
  final String photoBeforeUrl;
  final String? photoAfterUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpotModel({
    required this.id,
    this.reporterId,
    this.cleanerId,
    required this.lat,
    required this.lon,
    this.pollutionScoreBefore,
    this.pollutionScoreAfter,
    this.detectedMaterials,
    required this.photoBeforeUrl,
    this.photoAfterUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String?,
      cleanerId: json['cleaner_id'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      pollutionScoreBefore: json['pollution_score_before'] as int?,
      pollutionScoreAfter: json['pollution_score_after'] as int?,
      detectedMaterials: (json['detected_materials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      photoBeforeUrl: json['photo_before_url'] as String,
      photoAfterUrl: json['photo_after_url'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class HeatmapPointModel {
  final double lat;
  final double lon;
  final double weight;
  final String status;
  final String spotId;

  HeatmapPointModel({
    required this.lat,
    required this.lon,
    required this.weight,
    required this.status,
    required this.spotId,
  });

  factory HeatmapPointModel.fromJson(Map<String, dynamic> json) {
    return HeatmapPointModel(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      status: json['status'] as String,
      spotId: json['spot_id'] as String,
    );
  }
}

class LeaderboardUserModel {
  final String id;
  final String nickname;
  final int ratingPoints;
  final String region;
  final String? avatarUrl;
  final int spotsFoundCount;
  final int spotsCleanedCount;

  LeaderboardUserModel({
    required this.id,
    required this.nickname,
    required this.ratingPoints,
    required this.region,
    this.avatarUrl,
    required this.spotsFoundCount,
    required this.spotsCleanedCount,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      ratingPoints: json['rating_points'] as int,
      region: json['region'] as String,
      avatarUrl: json['avatar_url'] as String?,
      spotsFoundCount: json['spots_found_count'] as int,
      spotsCleanedCount: json['spots_cleaned_count'] as int,
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final LeaderboardUserModel user;
  final int? pointsToNextRank;

  LeaderboardEntryModel({
    required this.rank,
    required this.user,
    this.pointsToNextRank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      user: LeaderboardUserModel.fromJson(json['user'] as Map<String, dynamic>),
      pointsToNextRank: json['points_to_next_rank'] as int?,
    );
  }
}