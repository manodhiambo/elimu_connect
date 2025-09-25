class ElimuStringUtils {
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String formatPhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('254')) {
      return '+$clean';
    } else if (clean.startsWith('0')) {
      return '+254${clean.substring(1)}';
    }
    return '+254$clean';
  }
}
