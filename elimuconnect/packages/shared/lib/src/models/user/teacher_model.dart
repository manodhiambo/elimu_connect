import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherRegistrationRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String tscNumber; // Teachers Service Commission number
  final String schoolId;
  final List<String> subjectsTaught;
  final List<String> classesAssigned;
  final String qualification;
  final int yearsOfExperience;
  final String? specialization;

  const TeacherRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.tscNumber,
    required this.schoolId,
    required this.subjectsTaught,
    required this.classesAssigned,
    required this.qualification,
    required this.yearsOfExperience,
    this.specialization,
  });

  factory TeacherRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$TeacherRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        phoneNumber,
        tscNumber,
        schoolId,
        subjectsTaught,
        classesAssigned,
        qualification,
        yearsOfExperience,
        specialization,
      ];
}

@JsonSerializable()
class TeacherProfile extends Equatable {
  final UserModel user;
  final String tscNumber;
  final String schoolId;
  final List<String> subjectsTaught;
  final List<String> classesAssigned;
  final String qualification;
  final int yearsOfExperience;
  final String? specialization;
  final double rating;
  final int studentsCount;
  final bool isClassTeacher;
  final String? classTeacherFor;

  const TeacherProfile({
    required this.user,
    required this.tscNumber,
    required this.schoolId,
    required this.subjectsTaught,
    required this.classesAssigned,
    required this.qualification,
    required this.yearsOfExperience,
    this.specialization,
    this.rating = 0.0,
    this.studentsCount = 0,
    this.isClassTeacher = false,
    this.classTeacherFor,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) =>
      _$TeacherProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherProfileToJson(this);

  @override
  List<Object?> get props => [
        user,
        tscNumber,
        schoolId,
        subjectsTaught,
        classesAssigned,
        qualification,
        yearsOfExperience,
        specialization,
        rating,
        studentsCount,
        isClassTeacher,
        classTeacherFor,
      ];
}
