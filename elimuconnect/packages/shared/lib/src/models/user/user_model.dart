import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../common/enums.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.status,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, email, phoneNumber, role, status, 
    profileImageUrl, createdAt, updatedAt
  ];
}
