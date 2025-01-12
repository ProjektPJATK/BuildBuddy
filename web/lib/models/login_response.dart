class LoginResponse {
  final String token;
  final int userId;
  final List<Map<String, dynamic>> rolesInTeams;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.rolesInTeams,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      userId: json['userId'],
      rolesInTeams: (json['rolesInTeams'] as List<dynamic>).map((role) {
        return {
          'teamId': role['teamId'],
          'powerLevel': role['powerLevel'],
        };
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'rolesInTeams': rolesInTeams,
    };
  }
}
