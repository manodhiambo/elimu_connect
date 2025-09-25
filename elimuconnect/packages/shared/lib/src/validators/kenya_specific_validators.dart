// File: packages/shared/lib/src/validators/kenya_specific_validators.dart
import '../constants/kenya_curriculum.dart';
import '../models/common/enums.dart';

class KenyaSpecificValidators {
  static String? validateTscNumber(String? tscNumber) {
    if (tscNumber == null || tscNumber.isEmpty) {
      return 'TSC number is required for teacher registration';
    }
    
    // TSC numbers typically follow pattern: TSC/12345/2020
    final tscRegex = RegExp(r'^TSC\/\d{4,6}\/\d{4}$');
    if (!tscRegex.hasMatch(tscNumber.toUpperCase())) {
      return 'Please enter a valid TSC number (format: TSC/12345/2020)';
    }
    
    return null;
  }
  
  static String? validateNationalId(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) {
      return 'National ID is required';
    }
    
    // Kenyan ID numbers are typically 7-8 digits
    if (nationalId.length < 7 || nationalId.length > 8) {
      return 'Please enter a valid National ID number';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(nationalId)) {
      return 'National ID should contain only numbers';
    }
    
    return null;
  }
  
  static String? validateAdmissionNumber(String? admissionNumber) {
    if (admissionNumber == null || admissionNumber.isEmpty) {
      return 'Admission number is required';
    }
    
    if (admissionNumber.length < 3) {
      return 'Admission number is too short';
    }
    
    return null;
  }
  
  static String? validateSchoolId(String? schoolId) {
    if (schoolId == null || schoolId.isEmpty) {
      return 'School selection is required';
    }
    
    return null;
  }
  
  static String? validateClassName(String? className) {
    if (className == null || className.isEmpty) {
      return 'Class selection is required';
    }
    
    if (!KenyaCurriculum.gradeNames.contains(className)) {
      return 'Please select a valid class';
    }
    
    return null;
  }
  
  static String? validateSubjects(List<String>? subjects) {
    if (subjects == null || subjects.isEmpty) {
      return 'At least one subject must be selected';
    }
    
    return null;
  }
  
  static String? validateQualification(String? qualification) {
    if (qualification == null || qualification.isEmpty) {
      return 'Educational qualification is required';
    }
    
    final validQualifications = [
      'Certificate in Education',
      'Diploma in Education',
      "Bachelor's Degree in Education",
      "Master's Degree in Education",
      'PhD in Education',
    ];
    
    if (!validQualifications.contains(qualification)) {
      return 'Please select a valid teaching qualification';
    }
    
    return null;
  }
  
  static String? validateKenyanPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check for valid Kenyan number formats
    if (cleanNumber.startsWith('+254')) {
      cleanNumber = cleanNumber.substring(4);
    } else if (cleanNumber.startsWith('254')) {
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }
    
    // Should be 9 digits after country code
    if (cleanNumber.length != 9) {
      return 'Please enter a valid Kenyan phone number';
    }
    
    // Should start with 7 (mobile) or 1 (landline in some areas)
    if (!cleanNumber.startsWith('7') && !cleanNumber.startsWith('1')) {
      return 'Please enter a valid Kenyan phone number';
    }
    
    return null;
  }
}
