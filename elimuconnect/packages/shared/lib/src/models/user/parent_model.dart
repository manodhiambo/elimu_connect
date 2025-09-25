import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'parent_model.g.dart';

@JsonSerializable()
class ParentRegistrationRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String nationalId;
  final List<String> childrenAdmissionNumbers;
  final String relationshipToChildren;
  final String address;
  final String? occupation;
  final String? emergencyContact;

  const ParentRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.nationalId,
    required this.childrenAdmissionNumbers,
    required this.relationshipToChildren,
    required this.address,
    this.occupation,
    this.emergencyContact,
  });

  factory ParentRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$ParentRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ParentRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        phoneNumber,
        nationalId,
        childrenAdmissionNumbers,
        relationshipToChildren,
        address,
        occupation,
        emergencyContact,
      ];
}

@JsonSerializable()
class ParentProfile extends Equatable {
  final UserModel user;
  final String nationalId;
  final List<String> childrenIds;
  final String relationshipToChildren;
  final String address;
  final String? occupation;
  final String? emergencyContact;
  final bool receiveNotifications;
  final bool receiveSmsUpdates;
  final DateTime lastActiveDate;

  const ParentProfile({
    required this.user,
    required this.nationalId,
    required this.childrenIds,
    required this.relationshipToChildren,
    required this.address,
    this.occupation,
    this.emergencyContact,
    this.receiveNotifications = true,
    this.receiveSmsUpdates = true,
    required this.lastActiveDate,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) =>
      _$ParentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ParentProfileToJson(this);

  @override
  List<Object?> get props => [
        user,
        nationalId,
        childrenIds,
        relationshipToChildren,
        address,
        occupation,
        emergencyContact,
        receiveNotifications,
        receiveSmsUpdates,
        lastActiveDate,
      ];
}
