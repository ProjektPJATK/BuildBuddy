class AppConfig {
  static const String backendIP = "192.168.0.185"; // Zmień na swoje IP w razie potrzeby
  static const String backendPort = "5007";
  // Konstrukcja pełnego URL
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  // Dodatkowe endpointy
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
}