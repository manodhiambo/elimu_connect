import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentRegistrationRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String admissionNumber;
  final String schoolId;
  final String className;
  final DateTime dateOfBirth;
  final String parentGuardianContact;
  final String countyOfResidence;
  final String? previousSchool;
  final String? specialNeeds;

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
    this.previousSchool,
    this.specialNeeds,
  });

  factory StudentRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$StudentRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StudentRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        admissionNumber,
        schoolId,
        className,
        dateOfBirth,
        parentGuardianContact,
        countyOfResidence,
        previousSchool,
        specialNeeds,
      ];
}

@JsonSerializable()
class StudentProfile extends Equatable {
  final UserModel user;
  final String admissionNumber;
  final String schoolId;
  final String className;
  final DateTime dateOfBirth;
  final String parentGuardianContact;
  final String countyOfResidence;
  final List<String> subjects;
  final double averageGrade;
  final int totalAssignments;
  final int completedAssignments;
  final String? previousSchool;
  final String? specialNeeds;
  final DateTime enrollmentDate;

  const StudentProfile({
    required this.user,
    required this.admissionNumber,
    required this.schoolId,
    required this.className,
    required this.dateOfBirth,
    required this.parentGuardianContact,
    required this.countyOfResidence,
    required this.subjects,
    this.averageGrade = 0.0,
    this.totalAssignments = 0,
    this.completedAssignments = 0,
    this.previousSchool,
    this.specialNeeds,
    required this.enrollmentDate,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);

  double get completionRate => totalAssignments > 0 
      ? (completedAssignments / totalAssignments) * 100 
      : 0.0;

  @override
  List<Object?> get props => [
        user,
        admissionNumber,
        schoolId,
        className,
        dateOfBirth,
        parentGuardianContact,
        countyOfResidence,
        subjects,
        averageGrade,
        totalAssignments,
        completedAssignments,
        previousSchool,
        specialNeeds,
        enrollmentDate,
      ];
}
