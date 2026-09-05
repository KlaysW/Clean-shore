class TokenModel {
  final String accessToken;
  final String tokenType;

  TokenModel({required this.accessToken, required this.tokenType});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String nickname;
  final int ratingPoints;
  final String region;
  final bool isOoptStaff;
  final String? avatarUrl;
  final int spotsFoundCount;
  final int spotsCleanedCount;

  UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    required this.ratingPoints,
    required this.region,
    required this.isOoptStaff,
    this.avatarUrl,
    required this.spotsFoundCount,
    required this.spotsCleanedCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      ratingPoints: json['rating_points'] as int,
      region: json['region'] as String,
      isOoptStaff: json['is_oopt_staff'] as bool,
      avatarUrl: json['avatar_url'] as String?,
      spotsFoundCount: json['spots_found_count'] as int,
      spotsCleanedCount: json['spots_cleaned_count'] as int,
    );
  }
}