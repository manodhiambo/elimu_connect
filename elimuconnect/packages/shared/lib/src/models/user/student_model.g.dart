// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentRegistrationRequest _$StudentRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    StudentRegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      admissionNumber: json['admissionNumber'] as String,
      schoolId: json['schoolId'] as String,
      className: json['className'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      parentGuardianContact: json['parentGuardianContact'] as String,
      countyOfResidence: json['countyOfResidence'] as String,
      previousSchool: json['previousSchool'] as String?,
      specialNeeds: json['specialNeeds'] as String?,
    );

Map<String, dynamic> _$StudentRegistrationRequestToJson(
        StudentRegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'admissionNumber': instance.admissionNumber,
      'schoolId': instance.schoolId,
      'className': instance.className,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'parentGuardianContact': instance.parentGuardianContact,
      'countyOfResidence': instance.countyOfResidence,
      'previousSchool': instance.previousSchool,
      'specialNeeds': instance.specialNeeds,
    };

StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    StudentProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      admissionNumber: json['admissionNumber'] as String,
      schoolId: json['schoolId'] as String,
      className: json['className'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      parentGuardianContact: json['parentGuardianContact'] as String,
      countyOfResidence: json['countyOfResidence'] as String,
      subjects:
          (json['subjects'] as List<dynamic>).map((e) => e as String).toList(),
      averageGrade: (json['averageGrade'] as num?)?.toDouble() ?? 0.0,
      totalAssignments: (json['totalAssignments'] as num?)?.toInt() ?? 0,
      completedAssignments:
          (json['completedAssignments'] as num?)?.toInt() ?? 0,
      previousSchool: json['previousSchool'] as String?,
      specialNeeds: json['specialNeeds'] as String?,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
    );

Map<String, dynamic> _$StudentProfileToJson(StudentProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'admissionNumber': instance.admissionNumber,
      'schoolId': instance.schoolId,
      'className': instance.className,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'parentGuardianContact': instance.parentGuardianContact,
      'countyOfResidence': instance.countyOfResidence,
      'subjects': instance.subjects,
      'averageGrade': instance.averageGrade,
      'totalAssignments': instance.totalAssignments,
      'completedAssignments': instance.completedAssignments,
      'previousSchool': instance.previousSchool,
      'specialNeeds': instance.specialNeeds,
      'enrollmentDate': instance.enrollmentDate.toIso8601String(),
    };
