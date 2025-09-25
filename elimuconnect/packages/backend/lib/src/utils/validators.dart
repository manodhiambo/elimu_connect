class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, uppercase, lowercase, number, special character
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  static bool isValidKenyanPhone(String phone) {
    // Kenyan phone number patterns
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
    return RegExp(r'^(?:\+254|0)([17]\d{8})$').hasMatch(cleanPhone);
  }

  static bool isValidKenyanNationalId(String nationalId) {
    // Kenyan national ID is typically 8 digits
    return RegExp(r'^\d{8}$').hasMatch(nationalId);
  }

  static bool isValidTSCNumber(String tscNumber) {
    // TSC numbers follow pattern: TSC/12345/2020
    return RegExp(r'^TSC\/\d{5}\/\d{4}$').hasMatch(tscNumber);
  }

  static bool isValidNEMISCode(String nemisCode) {
    // NEMIS codes are typically numeric with specific length
    return RegExp(r'^\d{8,12}$').hasMatch(nemisCode);
  }

  static bool isValidAdmissionNumber(String admissionNumber) {
    // Admission numbers vary but should be alphanumeric
    return RegExp(r'^[A-Za-z0-9\-\/]{3,20}$').hasMatch(admissionNumber);
  }

  static bool isStrongPassword(String password) {
    if (password.length < 12) return false;
    
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigits = RegExp(r'\d').hasMatch(password);
    bool hasSpecialCharacters = RegExp(r'[@$!%*?&]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }
}
