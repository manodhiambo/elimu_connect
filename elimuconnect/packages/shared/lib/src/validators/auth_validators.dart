import '../constants/app_constants.dart';

class AuthValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    if (email.length > AppConstants.maxEmailLength) {
      return 'Email is too long';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (name.length > AppConstants.maxNameLength) {
      return 'Name is too long';
    }
    
    if (!name.contains(RegExp(r'^[a-zA-Z\s]+$'))) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  static String? validateAdminCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Admin registration code is required';
    }
    
    if (code != AppConstants.adminRegistrationCode) {
      return 'Invalid admin registration code';
    }
    
    return null;
  }
}
