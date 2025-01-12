class AppConfig {
  static const String backendIP = "127.0.0.1"; 
  static const String backendPort = "5159";
  static const String backendChatPort = "5088";

  static String getBaseUrl() => "http://$backendIP:$backendPort";
  static String getChatUrl() => "http://$backendIP:$backendChatPort";


  static String getRoleEndpoint(int roleId) => "${getBaseUrl()}/api/Roles/$roleId";
  // API Endpoints
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
  static String getProfileEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
  static String getInventoryEndpoint(int addressId) =>
      "${getBaseUrl()}/api/BuildingArticles/address/$addressId";
  static String getTeammatesEndpoint(int teamId) => "${getBaseUrl()}/api/Team/$teamId/users";
  static String getChatListEndpoint(int userId) =>
      '${getBaseUrl()}/api/Conversation/user/$userId/conversations';
  static String createConversationEndpoint() => '${getBaseUrl()}/api/Conversation/create';
  static String registerEndpoint() => '${getBaseUrl()}/api/User/register';
  static String getUpdateInventoryItemEndpoint(int itemId) =>
    '${getBaseUrl()}/api/BuildingArticles/$itemId';



  
  // Nowe endpointy
  static String exitChatEndpoint(int conversationId, int userId) => 
      '${getBaseUrl()}/api/Chat/exit-chat?conversationId=$conversationId&userId=$userId';
  
  static String unreadCountEndpoint(int conversationId, int userId) =>
      '${getBaseUrl()}/api/Chat/unread-count?conversationId=$conversationId&userId=$userId';

  // Endpoints for Job Actualization
  static String getJobActualizationEndpoint(int jobId) =>
      '${getBaseUrl()}/api/JobActualization/$jobId';
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

  // New Endpoint for Job Actualization by User ID and Address
  static String getUserJobActualizationByAddress(int userId, int addressId) =>
      '${getBaseUrl()}/api/Job/user/$userId/address/$addressId';
       static String getAddressEndpoint(int addressId) => "${getBaseUrl()}/api/Address/$addressId";

       // Fetch jobs by address ID
static String getJobsByAddressEndpoint(int addressId) =>
    '${getBaseUrl()}/api/Job/address/$addressId';

// Toggle job actualization status
static String toggleJobActualizationStatusEndpoint(int id) =>
    '${getBaseUrl()}/api/JobActualization/$id/toggle-status';

}
  
