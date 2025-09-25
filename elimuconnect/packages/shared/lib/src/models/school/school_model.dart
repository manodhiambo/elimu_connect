import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../common/enums.dart';

part 'school_model.g.dart';

@JsonSerializable()
class SchoolModel extends Equatable {
  final String id;
  final String name;
  final String nemisCode;
  final SchoolType schoolType;
  final County county;
  final String subcounty;
  final String ward;
  final String address;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final GradeLevel lowestGrade;
  final GradeLevel highestGrade;
  final int totalStudents;
  final int totalTeachers;
  final bool isActive;
  final DateTime establishedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.nemisCode,
    required this.schoolType,
    required this.county,
    required this.subcounty,
    required this.ward,
    required this.address,
    this.phoneNumber,
    this.email,
    this.website,
    required this.lowestGrade,
    required this.highestGrade,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.isActive = true,
    required this.establishedDate,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolModelToJson(this);

  SchoolModel copyWith({
    String? id,
    String? name,
    String? nemisCode,
    SchoolType? schoolType,
    County? county,
    String? subcounty,
    String? ward,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    GradeLevel? lowestGrade,
    GradeLevel? highestGrade,
    int? totalStudents,
    int? totalTeachers,
    bool? isActive,
    DateTime? establishedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nemisCode: nemisCode ?? this.nemisCode,
      schoolType: schoolType ?? this.schoolType,
      county: county ?? this.county,
      subcounty: subcounty ?? this.subcounty,
      ward: ward ?? this.ward,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      lowestGrade: lowestGrade ?? this.lowestGrade,
      highestGrade: highestGrade ?? this.highestGrade,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      isActive: isActive ?? this.isActive,
      establishedDate: establishedDate ?? this.establishedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nemisCode,
        schoolType,
        county,
        subcounty,
        ward,
        address,
        phoneNumber,
        email,
        website,
        lowestGrade,
        highestGrade,
        totalStudents,
        totalTeachers,
        isActive,
        establishedDate,
        createdAt,
        updatedAt,
        metadata,
      ];
}

@JsonSerializable()
class SchoolRegistrationRequest extends Equatable {
  final String name;
  final String nemisCode;
  final SchoolType schoolType;
  final County county;
  final String subcounty;
  final String ward;
  final String address;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final GradeLevel lowestGrade;
  final GradeLevel highestGrade;
  final DateTime establishedDate;

  const SchoolRegistrationRequest({
    required this.name,
    required this.nemisCode,
    required this.schoolType,
    required this.county,
    required this.subcounty,
    required this.ward,
    required this.address,
    this.phoneNumber,
    this.email,
    this.website,
    required this.lowestGrade,
    required this.highestGrade,
    required this.establishedDate,
  });

  factory SchoolRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$SchoolRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        nemisCode,
        schoolType,
        county,
        subcounty,
        ward,
        address,
        phoneNumber,
        email,
        website,
        lowestGrade,
        highestGrade,
        establishedDate,
      ];
}
