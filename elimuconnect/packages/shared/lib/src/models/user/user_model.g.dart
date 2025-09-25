// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// Temporary placeholder implementations
Map<String, dynamic> _$UserToJson(User instance) => {
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'role': instance.role.name,
  'status': instance.status.name,
  'profileImageUrl': instance.profileImageUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  role: UserRole.values.byName(json['role'] as String),
  status: UserStatus.values.byName(json['status'] as String),
  profileImageUrl: json['profileImageUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);
