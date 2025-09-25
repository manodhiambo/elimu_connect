class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';

  // Auth endpoints
  static const String authBase = '/auth';
  static const String loginEndpoint = '$authBase/login';
  static const String registerAdminEndpoint = '$authBase/register/admin';
  static const String registerTeacherEndpoint = '$authBase/register/teacher';
  static const String registerStudentEndpoint = '$authBase/register/student';
  static const String registerParentEndpoint = '$authBase/register/parent';
  static const String refreshTokenEndpoint = '$authBase/refresh';
  static const String forgotPasswordEndpoint = '$authBase/forgot-password';
  static const String resetPasswordEndpoint = '$authBase/reset-password';
  static const String profileEndpoint = '$authBase/me';
  static const String logoutEndpoint = '$authBase/logout';

  // User endpoints
  static const String usersBase = '/users';
  static const String getUserEndpoint = '$usersBase/{id}';
  static const String updateUserEndpoint = '$usersBase/{id}';
  static const String deleteUserEndpoint = '$usersBase/{id}';
  static const String getUsersEndpoint = usersBase;

  // School endpoints
  static const String schoolsBase = '/schools';
  static const String getSchoolEndpoint = '$schoolsBase/{id}';
  static const String createSchoolEndpoint = schoolsBase;
  static const String updateSchoolEndpoint = '$schoolsBase/{id}';
  static const String getSchoolsEndpoint = schoolsBase;
  static const String searchSchoolsEndpoint = '$schoolsBase/search';

  // Content endpoints
  static const String contentBase = '/content';
  static const String getContentEndpoint = '$contentBase/{id}';
  static const String createContentEndpoint = contentBase;
  static const String updateContentEndpoint = '$contentBase/{id}';
  static const String deleteContentEndpoint = '$contentBase/{id}';
  static const String getContentsEndpoint = contentBase;
  static const String searchContentEndpoint = '$contentBase/search';
  static const String uploadContentEndpoint = '$contentBase/upload';

  // Assessment endpoints
  static const String assessmentsBase = '/assessments';
  static const String getAssessmentEndpoint = '$assessmentsBase/{id}';
  static const String createAssessmentEndpoint = assessmentsBase;
  static const String submitAssessmentEndpoint = '$assessmentsBase/{id}/submit';
  static const String getResultsEndpoint = '$assessmentsBase/{id}/results';

  // Message endpoints
  static const String messagesBase = '/messages';
  static const String getConversationsEndpoint = messagesBase;
  static const String sendMessageEndpoint = messagesBase;
  static const String getMessagesEndpoint = '$messagesBase/{conversationId}';

  // File upload
  static const String uploadsBase = '/uploads';
  static const String uploadFileEndpoint = uploadsBase;
  static const String getFileEndpoint = '$uploadsBase/{filename}';

  // Request timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 60;
  static const int sendTimeout = 60;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File upload limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp'
  ];
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain'
  ];
  static const List<String> allowedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/ogg'
  ];
  static const List<String> allowedAudioTypes = [
    'audio/mp3',
    'audio/wav',
    'audio/ogg'
  ];
}
