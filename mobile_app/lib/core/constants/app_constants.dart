class AppConstants {
  AppConstants._();

  static const String appName = 'Чистый берег';
  static const String appTagline = 'Экологический мониторинг и квесты';

  static const double spatialDedupRadiusMeters = 15.0;

  static const int ratingSearchMin = 50;
  static const int ratingSearchMax = 250;
  static const int ratingCleanupMin = 200;
  static const int ratingCleanupMax = 2000;

  static const int leaderboardTopSize = 50;
}

enum SpotStatus {
  active('ACTIVE'),
  inProgress('IN_PROGRESS'),
  cleaned('CLEANED');

  final String value;

  const SpotStatus(this.value);

  static SpotStatus fromString(String value) {
    return SpotStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SpotStatus.active,
    );
  }
}

enum QuestMode {
  search,
  cleanup,
}