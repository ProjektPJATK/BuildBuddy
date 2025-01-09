class AppConfig {
  static const String backendIP = "10.0.2.2"; // Change to your IP if needed
  static const String backendPort = "5159";
  static const String backendChatPort = "5088";

  // S3 Base URL for images
  static const String s3BaseUrl = "https://buildbuddybucket.s3.amazonaws.com";

  // Base URLs
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  static String getChatUrl() => "http://$backendIP:$backendChatPort";

  // API Endpoints
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
  static String getProfileEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
  static String getInventoryEndpoint(int placeId) =>
      "${getBaseUrl()}/api/BuildingArticles/address/1?placeId=$placeId";
  static String getTeammatesEndpoint(int teamId) => "${getBaseUrl()}/api/Team/$teamId/users";
  static String getChatListEndpoint(int userId) =>
      '${getBaseUrl()}/api/Conversation/user/$userId/conversations';
  static String createConversationEndpoint() => '${getBaseUrl()}/api/Conversation/create';
  static String registerEndpoint() => '${getBaseUrl()}/api/User/register';

  // Endpoints for Job Actualization
  static String getJobActualizationEndpoint(int jobId) =>
      '${getBaseUrl()}/api/Job/$jobId/actualizations'; // Uses jobId now
  static String postAddImageEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/add-image';
  static String deleteImageEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/delete-image';
  static String getImagesEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/images';

  // User Endpoints
  static String getUserJobEndpoint(int userId) => '${getBaseUrl()}/api/Job/user/$userId';
  static String postJobActualizationEndpoint() => '${getBaseUrl()}/api/JobActualization';

  static String uploadUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/upload-image";
  static String getUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/image";
  static String patchUserEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
}
