class ApiConstants {
  // Remote Hosting Base URL:
  static const String baseUrl = 'http://www.apps.ourhw.online';
  static const String imageBaseUrl = baseUrl;

  // Auth endpoints
  static const String registerStudent = '$baseUrl/api/Auth/register-student';
  static const String registerTeacher = '$baseUrl/api/Auth/register-teacher';
  static const String login = '$baseUrl/api/Auth/login';
  static const String me = '$baseUrl/api/Auth/me';
  static const String changePassword = '$baseUrl/api/Auth/change-password';

  // Academic endpoints
  static const String curriculums = '$baseUrl/api/Academic/curriculums';
  static const String classes = '$baseUrl/api/Academic/classes';
  static const String subjects = '$baseUrl/api/Academic/subjects';

  // Problem Feed endpoints
  static const String createProblem = '$baseUrl/api/ProblemFeed/create';
  static const String feed = '$baseUrl/api/ProblemFeed/feed';
  static String problemDetails(int id) => '$baseUrl/api/ProblemFeed/$id';
  static String reply(int id) => '$baseUrl/api/ProblemFeed/$id/reply';
  static String toggleLike(int id) => '$baseUrl/api/ProblemFeed/reply/$id/like';

  // AI Assistant endpoint
  static const String aiSolve = '$baseUrl/api/Ai/solve';

  // Notification endpoints
  static const String notifications = '$baseUrl/api/Notification';
  static String markAsRead(int id) => '$baseUrl/api/Notification/$id/read';

  // Tuition Board endpoints
  static const String tuitionFeed = '$baseUrl/api/Tuition/feed';
  static const String createTuition = '$baseUrl/api/Tuition/create';
  static String applyTuition(int id) => '$baseUrl/api/Tuition/$id/apply';
  static String tuitionApplications(int id) => '$baseUrl/api/Tuition/$id/applications';
}
