bool isAluEmail(String email) {
  final value = email.trim().toLowerCase();
  return value.endsWith('@alustudent.com') ||
      value.endsWith('@alueducation.com');
}
