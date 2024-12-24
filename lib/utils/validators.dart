class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPort(String port) {
    if (port.isEmpty) return false;

    final number = int.tryParse(port);
    if (number == null) return false;

    return number > 0 && number <= 65535; // Valid port range
  }

  static bool isValidPassword(String password) {
    if (password.length < 12) return false;

    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasUniqueChars = password.split('').toSet().length >= 1;

    return hasDigit &&
        hasLowercase &&
        hasUppercase &&
        hasSpecialChar &&
        hasUniqueChars;
  }

  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 12) return 'Password must be at least 12 characters';
    if (!password.contains(RegExp(r'[0-9]')))
      return 'Password must contain a number';
    if (!password.contains(RegExp(r'[a-z]')))
      return 'Password must contain a lowercase letter';
    if (!password.contains(RegExp(r'[A-Z]')))
      return 'Password must contain an uppercase letter';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      return 'Password must contain a special character';
    return null;
  }

  // You can add more validation methods here
  // For example:
  // static bool isValidPassword(String password) { ... }
  // static bool isValidPhoneNumber(String phone) { ... }
}
