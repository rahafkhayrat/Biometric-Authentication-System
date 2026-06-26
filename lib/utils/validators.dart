bool isValidEmail(String email) {
  final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  return regex.hasMatch(email);
}

bool isValidPassword(String pass) => pass.length >= 6;
