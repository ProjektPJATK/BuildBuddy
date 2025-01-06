class User {
  final int id;
  final String name;
  final String surname;
  final String mail;
  final String telephoneNr;
  final String password;
  final String userImageUrl;
  final String preferredLanguage;

  User({
    this.id = 0,
    required this.name,
    required this.surname,
    required this.mail,
    required this.telephoneNr,
    required this.password,
    this.userImageUrl = "string",
    this.preferredLanguage = "pl",
  });

  // Metoda do konwersji na JSON
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
    };
  }
}
