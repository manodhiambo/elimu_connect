import '../constants/kenya_curriculum.dart';
import '../models/common/enums.dart';

class KenyaValidators {
  static bool isValidKenyanPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Patterns for Kenyan phone numbers
    final patterns = [
      RegExp(r'^\+254[17]\d{8}), // +254712345678
      RegExp(r'^254[17]\d{8}),   // 254712345678
      RegExp(r'^0[17]\d{8}),     // 0712345678
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  static bool isValidNationalId(String nationalId) {
    final cleanId = nationalId.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^\d{8}).hasMatch(cleanId);
  }

  static bool isValidNEMISCode(String nemisCode) {
    // NEMIS codes are typically 8-12 digits
    return RegExp(r'^\d{8,12}).hasMatch(nemisCode);
  }

  static bool isValidTSCNumber(String tscNumber) {
    // TSC number format: TSC/12345/2020 or TSC12345/2020
    return RegExp(r'^TSC\/?(\d{5})\/(\d{4}), caseSensitive: false)
        .hasMatch(tscNumber.toUpperCase());
  }

  static bool isValidAdmissionNumber(String admissionNumber) {
    // Admission numbers vary but typically alphanumeric, 3-20 characters
    return RegExp(r'^[A-Za-z0-9\/\-_]{3,20}).hasMatch(admissionNumber);
  }

  static bool isValidCounty(County county) {
    return County.values.contains(county);
  }

  static bool isValidSubjectForGrade(String subject, String grade) {
    return KenyaCurriculum.isValidSubjectForGrade(subject, grade);
  }

  static bool isValidGradeProgression(GradeLevel from, GradeLevel to) {
    final gradeOrder = [
      GradeLevel.pp1,
      GradeLevel.pp2,
      GradeLevel.grade1,
      GradeLevel.grade2,
      GradeLevel.grade3,
      GradeLevel.grade4,
      GradeLevel.grade5,
      GradeLevel.grade6,
      GradeLevel.grade7,
      GradeLevel.grade8,
      GradeLevel.grade9,
      GradeLevel.form1,
      GradeLevel.form2,
      GradeLevel.form3,
      GradeLevel.form4,
    ];
    
    final fromIndex = gradeOrder.indexOf(from);
    final toIndex = gradeOrder.indexOf(to);
    
    return fromIndex >= 0 && toIndex >= 0 && fromIndex <= toIndex;
  }

  static List<String> getKenyanCounties() {
    return County.values.map((county) => _countyToString(county)).toList();
  }

  static String _countyToString(County county) {
    return county.toString().split('.').last.replaceAll('_', ' ').toTitleCase();
  }

  static bool isValidKenyanEmail(String email) {
    // Standard email validation with Kenyan domain preferences
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4});
    return emailRegex.hasMatch(email.toLowerCase());
  }

  static bool isValidSchoolName(String name) {
    // School names should be 3-100 characters, allow letters, numbers, spaces, and common punctuation
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
