class AppConfig {
  static const String backendIP = "10.0.2.2"; // Zmień na swoje IP w razie potrzeby
  static const String backendPort = "5159";
  static const String backendChatPort = "5088";
  // Konstrukcja pełnego URL
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  static String getChatUrl() => "http://$backendIP:$backendChatPort";
  // Dodatkowe endpointy
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
  static String getProfileEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
  static String getInventoryEndpoint(int placeId) => "${getBaseUrl()}/api/Item/place/$placeId";
  static String getTeammatesEndpoint(int teamId) => "${getBaseUrl()}/api/Team/$teamId/users";
  static String getChatListEndpoint(int userId) => '${getBaseUrl()}/api/Conversation/user/$userId/conversations';
  static String createConversationEndpoint() => '${getBaseUrl()}/api/Conversation/create';
  static String registerEndpoint() => '${getBaseUrl()}/api/User/register';
  
  // Nowe endpointy
  static String exitChatEndpoint(int conversationId, int userId) => 
      '${getBaseUrl()}/api/Chat/exit-chat?conversationId=$conversationId&userId=$userId';
  
  static String unreadCountEndpoint(int conversationId, int userId) =>
      '${getBaseUrl()}/api/Chat/unread-count?conversationId=$conversationId&userId=$userId';
}
