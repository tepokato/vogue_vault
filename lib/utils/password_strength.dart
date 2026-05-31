enum PasswordStrength { weak, medium, strong }

PasswordStrength calculatePasswordStrength(String password) {
  var score = 0;

  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

  if (score >= 5) {
    return PasswordStrength.strong;
  }
  if (score >= 3) {
    return PasswordStrength.medium;
  }
  return PasswordStrength.weak;
}
