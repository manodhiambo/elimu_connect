import '../constants/kenya_curriculum.dart';
import '../models/common/enums.dart';

class KenyaValidators {
  static bool isValidKenyanPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    final patterns = [
      RegExp(r'^\+254[17]\d{8}$'),
      RegExp(r'^254[17]\d{8}$'),
      RegExp(r'^0[17]\d{8}$'),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  static bool isValidNationalId(String nationalId) {
    final cleanId = nationalId.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^\d{8}$').hasMatch(cleanId);
  }

  static bool isValidNEMISCode(String nemisCode) {
    return RegExp(r'^\d{8,12}$').hasMatch(nemisCode);
  }

  static bool isValidTSCNumber(String tscNumber) {
    return RegExp(r'^TSC\/?(\d{5})\/(\d{4})$', caseSensitive: false)
        .hasMatch(tscNumber.toUpperCase());
  }

  static bool isValidAdmissionNumber(String admissionNumber) {
    return RegExp(r'^[A-Za-z0-9\/\-_]{3,20}$').hasMatch(admissionNumber);
  }

  static bool isValidCounty(County county) {
    return County.values.contains(county);
  }

  static bool isValidSubjectForGrade(String subject, String grade) {
    return KenyaCurriculum.isValidSubjectForGrade(subject, grade);
  }

  static List<String> getKenyanCounties() {
    return County.values.map((county) => _countyToString(county)).toList();
  }

  static String _countyToString(County county) {
    return county.toString().split('.').last.replaceAll('_', ' ').toTitleCase();
  }

  static bool isValidKenyanEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.toLowerCase());
  }

  static bool isValidSchoolName(String name) {
    return RegExp(r"^[a-zA-Z0-9\s\-'\.]{3,100}$").hasMatch(name.trim());
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
