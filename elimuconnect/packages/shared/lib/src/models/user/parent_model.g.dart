// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentRegistrationRequest _$ParentRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    ParentRegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] as String,
      nationalId: json['nationalId'] as String,
      childrenAdmissionNumbers:
          (json['childrenAdmissionNumbers'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      relationshipToChildren: json['relationshipToChildren'] as String,
      address: json['address'] as String,
      occupation: json['occupation'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
    );

Map<String, dynamic> _$ParentRegistrationRequestToJson(
        ParentRegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'nationalId': instance.nationalId,
      'childrenAdmissionNumbers': instance.childrenAdmissionNumbers,
      'relationshipToChildren': instance.relationshipToChildren,
      'address': instance.address,
      'occupation': instance.occupation,
      'emergencyContact': instance.emergencyContact,
    };

ParentProfile _$ParentProfileFromJson(Map<String, dynamic> json) =>
    ParentProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      nationalId: json['nationalId'] as String,
      childrenIds: (json['childrenIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relationshipToChildren: json['relationshipToChildren'] as String,
      address: json['address'] as String,
      occupation: json['occupation'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      receiveNotifications: json['receiveNotifications'] as bool? ?? true,
      receiveSmsUpdates: json['receiveSmsUpdates'] as bool? ?? true,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
    );

Map<String, dynamic> _$ParentProfileToJson(ParentProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'nationalId': instance.nationalId,
      'childrenIds': instance.childrenIds,
      'relationshipToChildren': instance.relationshipToChildren,
      'address': instance.address,
      'occupation': instance.occupation,
      'emergencyContact': instance.emergencyContact,
      'receiveNotifications': instance.receiveNotifications,
      'receiveSmsUpdates': instance.receiveSmsUpdates,
      'lastActiveDate': instance.lastActiveDate.toIso8601String(),
    };
