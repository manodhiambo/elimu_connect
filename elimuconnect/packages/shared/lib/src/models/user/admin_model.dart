import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'admin_model.g.dart';

@JsonSerializable()
class AdminRegistrationRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String adminCode;
  final String institutionId;
  final String? phoneNumber;

  const AdminRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.adminCode,
    required this.institutionId,
    this.phoneNumber,
  });

  factory AdminRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        adminCode,
        institutionId,
        phoneNumber,
      ];
}

@JsonSerializable()
class AdminProfile extends Equatable {
  final UserModel user;
  final String institutionId;
  final List<String> permissions;
  final AdminLevel level;
  final DateTime lastLogin;

  const AdminProfile({
    required this.user,
    required this.institutionId,
    required this.permissions,
    required this.level,
    required this.lastLogin,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) =>
      _$AdminProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AdminProfileToJson(this);

  @override
  List<Object?> get props => [
        user,
        institutionId,
        permissions,
        level,
        lastLogin,
      ];
}

enum AdminLevel {
  @JsonValue('super_admin')
  superAdmin,
  @JsonValue('school_admin')
  schoolAdmin,
  @JsonValue('county_admin')
  countyAdmin,
}
