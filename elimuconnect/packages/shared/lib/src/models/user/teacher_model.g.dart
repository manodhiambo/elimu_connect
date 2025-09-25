// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherRegistrationRequest _$TeacherRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    TeacherRegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] as String,
      tscNumber: json['tscNumber'] as String,
      schoolId: json['schoolId'] as String,
      subjectsTaught: (json['subjectsTaught'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      classesAssigned: (json['classesAssigned'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      qualification: json['qualification'] as String,
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      specialization: json['specialization'] as String?,
    );

Map<String, dynamic> _$TeacherRegistrationRequestToJson(
        TeacherRegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'tscNumber': instance.tscNumber,
      'schoolId': instance.schoolId,
      'subjectsTaught': instance.subjectsTaught,
      'classesAssigned': instance.classesAssigned,
      'qualification': instance.qualification,
      'yearsOfExperience': instance.yearsOfExperience,
      'specialization': instance.specialization,
    };

TeacherProfile _$TeacherProfileFromJson(Map<String, dynamic> json) =>
    TeacherProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tscNumber: json['tscNumber'] as String,
      schoolId: json['schoolId'] as String,
      subjectsTaught: (json['subjectsTaught'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      classesAssigned: (json['classesAssigned'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      qualification: json['qualification'] as String,
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      specialization: json['specialization'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
      classTeacherFor: json['classTeacherFor'] as String?,
    );

Map<String, dynamic> _$TeacherProfileToJson(TeacherProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'tscNumber': instance.tscNumber,
      'schoolId': instance.schoolId,
      'subjectsTaught': instance.subjectsTaught,
      'classesAssigned': instance.classesAssigned,
      'qualification': instance.qualification,
      'yearsOfExperience': instance.yearsOfExperience,
      'specialization': instance.specialization,
      'rating': instance.rating,
      'studentsCount': instance.studentsCount,
      'isClassTeacher': instance.isClassTeacher,
      'classTeacherFor': instance.classTeacherFor,
    };
