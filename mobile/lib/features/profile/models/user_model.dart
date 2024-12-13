class User {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String telephoneNr;
  final String? password;
  final String userImageUrl;
  final String preferredLanguage;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.telephoneNr,
    this.password,
    required this.userImageUrl,
    required this.preferredLanguage,
  });

  // Metoda do deserializacji z JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['mail'],
      telephoneNr: json['telephoneNr'],
      password: json['password'],
      userImageUrl: json['userImageUrl'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? 'en',
    );
  }

  // Metoda do serializacji do JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'mail': email,
      'telephoneNr': telephoneNr,
      'password': password,
      'userImageUrl': userImageUrl,
      'preferredLanguage': preferredLanguage,
    };
  }
}
