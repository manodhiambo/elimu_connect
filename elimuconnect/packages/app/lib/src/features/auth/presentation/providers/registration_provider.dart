/ packages/app/lib/src/features/auth/presentation/providers/registration_provider.dart
final registrationFormProvider = StateNotifierProvider<RegistrationFormNotifier, RegistrationFormState>((ref) {
  return RegistrationFormNotifier();
});

class RegistrationFormNotifier extends StateNotifier<RegistrationFormState> {
  RegistrationFormNotifier() : super(RegistrationFormState.initial());
  
  void setUserRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }
  
  void updateField(String field, dynamic value) {
    state = state.copyWith(formData: {...state.formData, field: value});
  }
  
  bool validateForm() {
    // Role-specific validation logic
    switch (state.selectedRole) {
      case UserRole.admin:
        return _validateAdminForm();
      case UserRole.teacher:
        return _validateTeacherForm();
      case UserRole.student:
        return _validateStudentForm();
      case UserRole.parent:
        return _validateParentForm();
    }
  }
}
