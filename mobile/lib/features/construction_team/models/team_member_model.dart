class TeamMemberModel {
  final String id;
  final String name;
  final String role;
  final String phone;

  TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
    };
  }
}
