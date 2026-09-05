class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  static const String questSearch = '/quests/search';
  static const String questCleanup = '/quests/cleanup';
  static const String questUploadPhoto = '/quests/upload-photo';

  static const String mapSpots = '/map/spots';
  static const String mapHeatmap = '/map/heatmap';
  static const String leaderboard = '/leaderboard';

  static const String aiChatMessage = '/ai-chat/message';

  static const String oopPrioritySpots = '/oopt/dashboard/priority-spots';
  static const String oopVerifiedInspectors = '/oopt/dashboard/verified-inspectors';
  static const String oopApply = '/oopt/apply';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  static const String secureStorageTokenKey = 'clean_shore_access_token';
}