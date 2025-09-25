import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import '../common/enums.dart';

part 'admin_model.g.dart';

@JsonSerializable()
class Admin extends User {
  final String institutionId;
  final List<String> permissions;
  
  const Admin({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.status = UserStatus.active,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.institutionId,
    required this.permissions,
  }) : super(role: UserRole.admin);

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AdminToJson(this);

  @override
  List<Object?> get props => [...super.props, institutionId, permissions];
}

@JsonSerializable()
class AdminRegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String adminCode;
  final String institutionId;
  
  const AdminRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.adminCode,
    required this.institutionId,
  });
  
  factory AdminRegistrationRequest.fromJson(Map<String, dynamic> json) => 
      _$AdminRegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AdminRegistrationRequestToJson(this);
}
