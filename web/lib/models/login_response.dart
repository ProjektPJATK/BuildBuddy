class LoginResponse {
  final String token;
  final int userId;
  final int roleId;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.roleId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      userId: json['userId'],
      roleId: json['roleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'roleId': roleId,
    };
  }
}
