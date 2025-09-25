// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRegistrationRequest _$AdminRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    AdminRegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      adminCode: json['adminCode'] as String,
      institutionId: json['institutionId'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$AdminRegistrationRequestToJson(
        AdminRegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'adminCode': instance.adminCode,
      'institutionId': instance.institutionId,
      'phoneNumber': instance.phoneNumber,
    };

AdminProfile _$AdminProfileFromJson(Map<String, dynamic> json) => AdminProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      institutionId: json['institutionId'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      level: $enumDecode(_$AdminLevelEnumMap, json['level']),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );

Map<String, dynamic> _$AdminProfileToJson(AdminProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'institutionId': instance.institutionId,
      'permissions': instance.permissions,
      'level': _$AdminLevelEnumMap[instance.level]!,
      'lastLogin': instance.lastLogin.toIso8601String(),
    };

const _$AdminLevelEnumMap = {
  AdminLevel.superAdmin: 'super_admin',
  AdminLevel.schoolAdmin: 'school_admin',
  AdminLevel.countyAdmin: 'county_admin',
};
