// File: packages/shared/lib/src/models/user/student_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import '../common/enums.dart';

part 'student_model.g.dart';

@JsonSerializable()
class Student extends User {
  final String admissionNumber;
  final String schoolId;
  final String className;
  final DateTime dateOfBirth;
  final String parentGuardianContact;
  final KenyaCounty countyOfResidence;
  
  const Student({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.status = UserStatus.active,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.admissionNumber,
    required this.schoolId,
    required this.className,
    required this.dateOfBirth,
    required this.parentGuardianContact,
    required this.countyOfResidence,
  }) : super(role: UserRole.student);

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  @override
  List<Object?> get props => [
    ...super.props,
    admissionNumber,
    schoolId,
    className,
    dateOfBirth,
    parentGuardianContact,
    countyOfResidence,
  ];
}

@JsonSerializable()
class StudentRegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String admissionNumber;
  final String schoolId;
  final String className;
  final DateTime dateOfBirth;
  final String parentGuardianContact;
  final KenyaCounty countyOfResidence;
  
  const StudentRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.admissionNumber,
    required this.schoolId,
    required this.className,
    required this.dateOfBirth,
    required this.parentGuardianContact,
    required this.countyOfResidence,
  });
  
  factory StudentRegistrationRequest.fromJson(Map<String, dynamic> json) => 
      _$StudentRegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$StudentRegistrationRequestToJson(this);
}
