abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String surname;
  final String email;
  final String telephoneNr;
  final String password;

  RegisterSubmitted({
    required this.name,
    required this.surname,
    required this.email,
    required this.telephoneNr,
    required this.password,
  });
}
