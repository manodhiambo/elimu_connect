// File: packages/shared/lib/src/models/user/parent_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import '../common/enums.dart';

part 'parent_model.g.dart';

@JsonSerializable()
class Parent extends User {
  final String nationalId;
  final List<String> childrenAdmissionNumbers;
  final String relationshipToChildren;
  final String address;
  final KenyaCounty countyOfResidence;
  
  const Parent({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    super.status = UserStatus.active,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.nationalId,
    required this.childrenAdmissionNumbers,
    required this.relationshipToChildren,
    required this.address,
    required this.countyOfResidence,
  }) : super(role: UserRole.parent);

  factory Parent.fromJson(Map<String, dynamic> json) => _$ParentFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ParentToJson(this);

  @override
  List<Object?> get props => [
    ...super.props,
    nationalId,
    childrenAdmissionNumbers,
    relationshipToChildren,
    address,
    countyOfResidence,
  ];
}

@JsonSerializable()
class ParentRegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String nationalId;
  final List<String> childrenAdmissionNumbers;
  final String relationshipToChildren;
  final String address;
  final KenyaCounty countyOfResidence;
  
  const ParentRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.nationalId,
    required this.childrenAdmissionNumbers,
    required this.relationshipToChildren,
    required this.address,
    required this.countyOfResidence,
  });
  
  factory ParentRegistrationRequest.fromJson(Map<String, dynamic> json) => 
      _$ParentRegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ParentRegistrationRequestToJson(this);
}
