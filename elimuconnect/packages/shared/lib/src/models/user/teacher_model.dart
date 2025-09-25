// File: packages/shared/lib/src/models/user/teacher_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import '../common/enums.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class Teacher extends User {
  final String tscNumber;
  final String schoolId;
  final List<String> subjectsTaught;
  final List<String> classesAssigned;
  final String qualification;
  final KenyaCounty countyOfWork;
  
  const Teacher({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    super.status = UserStatus.active,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.tscNumber,
    required this.schoolId,
    required this.subjectsTaught,
    required this.classesAssigned,
    required this.qualification,
    required this.countyOfWork,
  }) : super(role: UserRole.teacher);

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TeacherToJson(this);

  @override
  List<Object?> get props => [
    ...super.props,
    tscNumber,
    schoolId,
    subjectsTaught,
    classesAssigned,
    qualification,
    countyOfWork,
  ];
}

@JsonSerializable()
class TeacherRegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String tscNumber;
  final String schoolId;
  final List<String> subjectsTaught;
  final List<String> classesAssigned;
  final String qualification;
  final KenyaCounty countyOfWork;
  
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
    required this.countyOfWork,
  });
  
  factory TeacherRegistrationRequest.fromJson(Map<String, dynamic> json) => 
      _$TeacherRegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherRegistrationRequestToJson(this);
}
