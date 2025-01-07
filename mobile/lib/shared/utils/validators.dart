class Validator {
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'To pole jest wymagane';
    } else if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value)) {
      return 'Wpisz poprawny numer telefonu';
    }
    return null;
  }
}
