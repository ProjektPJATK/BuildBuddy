class AppConfig {
  static const String backendIP = "10.0.2.2"; // Zmień na swoje IP w razie potrzeby
  static const String backendPort = "5159";
  static const String backendChatPort = "5088";
  
  // S3 Base URL for images
  static const String s3BaseUrl = "https://buildbuddybucket.s3.amazonaws.com";
  
  // Konstrukcja pełnego URL
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  static String getChatUrl() => "http://$backendIP:$backendChatPort";
  
  // Dodatkowe endpointy
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
  static String getProfileEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
   static String getInventoryEndpoint(int placeId) =>
      "${getBaseUrl()}/api/BuildingArticles/address/1?placeId=$placeId";
  static String getTeammatesEndpoint(int teamId) => "${getBaseUrl()}/api/Team/$teamId/users";
  static String getChatListEndpoint(int userId) => '${getBaseUrl()}/api/Conversation/user/$userId/conversations';
  static String createConversationEndpoint() => '${getBaseUrl()}/api/Conversation/create';
  static String registerEndpoint() => '${getBaseUrl()}/api/User/register';

  // Nowe endpointy dla JobActualization
  static String getJobActualizationEndpoint(int id) => '${getBaseUrl()}/api/JobActualization/$id';
  static String postAddImageEndpoint(int jobId) => '${getBaseUrl()}/api/JobActualization/$jobId/add-image';
  static String deleteImageEndpoint(int jobId) => '${getBaseUrl()}/api/JobActualization/$jobId/delete-image';
  static String getImagesEndpoint(int jobId) => '${getBaseUrl()}/api/JobActualization/$jobId/images';
  
  // Dodatkowy endpoint dla użytkownika
  static String getUserJobEndpoint(int userId) => '${getBaseUrl()}/api/Job/user/$userId';
  static String postJobActualizationEndpoint() => '${getBaseUrl()}/api/JobActualization';

  static String uploadUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/upload-image";
  static String getUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/image";
  static String patchUserEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
}
