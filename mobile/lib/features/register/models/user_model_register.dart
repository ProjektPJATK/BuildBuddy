class User {
  final int id;
  final String name;
  final String surname;
  final String mail;
  final String telephoneNr;
  final String password;
  final String userImageUrl;
  final String preferredLanguage;
  final List<RoleInTeam> rolesInTeams;

  User({
    this.id = 0,
    required this.name,
    required this.surname,
    required this.mail,
    required this.telephoneNr,
    required this.password,
    this.userImageUrl = "string",
    this.preferredLanguage = "pl",
    required this.rolesInTeams,
  });

  // Conversion to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "surname": surname,
      "mail": mail,
      "telephoneNr": telephoneNr,
      "password": password,
      "userImageUrl": userImageUrl,
      "preferredLanguage": preferredLanguage,
      "rolesInTeams": rolesInTeams.map((role) => role.toJson()).toList(),
    };
  }

  // Conversion from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'],
      surname: json['surname'],
      mail: json['mail'],
      telephoneNr: json['telephoneNr'],
      password: json['password'],
      userImageUrl: json['userImageUrl'] ?? "string",
      preferredLanguage: json['preferredLanguage'] ?? "pl",
      rolesInTeams: (json['rolesInTeams'] as List<dynamic>)
          .map((role) => RoleInTeam.fromJson(role))
          .toList(),
    );
  }
}

class RoleInTeam {
  final int teamId;
  final int roleId;

  RoleInTeam({required this.teamId, required this.roleId});

  Map<String, dynamic> toJson() {
    return {
      "teamId": teamId,
      "roleId": roleId,
    };
  }

  factory RoleInTeam.fromJson(Map<String, dynamic> json) {
    return RoleInTeam(
      teamId: json['teamId'],
      roleId: json['roleId'],
    );
  }
}
