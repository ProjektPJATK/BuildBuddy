class AppConfig {
  static const String backendIP = "10.0.2.2"; // Zmień na swoje IP w razie potrzeby
  static const String backendPort = "5159";
  // Konstrukcja pełnego URL
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  // Dodatkowe endpointy
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
}