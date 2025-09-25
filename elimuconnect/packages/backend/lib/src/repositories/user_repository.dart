import 'package:mongo_dart/mongo_dart.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../database/connection.dart';
import '../utils/exceptions.dart';

class UserRepository {
  DbCollection get _users => DatabaseConnection.mongo.collection('users');
  DbCollection get _teacherProfiles => DatabaseConnection.mongo.collection('teacher_profiles');
  DbCollection get _studentProfiles => DatabaseConnection.mongo.collection('student_profiles');
  DbCollection get _parentProfiles => DatabaseConnection.mongo.collection('parent_profiles');
  DbCollection get _adminProfiles => DatabaseConnection.mongo.collection('admin_profiles');

  Future<UserModel?> findByEmail(String email) async {
    try {
      final result = await _users.findOne(where.eq('email', email.toLowerCase()));
      if (result == null) return null;
      
      return UserModel.fromJson(result);
    } catch (e) {
      throw DatabaseException('Failed to find user by email: $e');
    }
  }

  Future<UserModel?> findById(String id) async {
    try {
      final objectId = ObjectId.parse(id);
      final result = await _users.findOne(where.eq('_id', objectId));
      if (result == null) return null;
      
      return UserModel.fromJson(result);
    } catch (e) {
      throw DatabaseException('Failed to find user by ID: $e');
    }
  }

  Future<UserModel> create(UserModel user, String passwordHash) async {
    try {
      final userData = user.toJson();
      userData['_id'] = ObjectId();
      userData['passwordHash'] = passwordHash;
      userData['email'] = user.email.toLowerCase();
      userData['createdAt'] = DateTime.now();
      userData['updatedAt'] = DateTime.now();

      await _users.insertOne(userData);
      
      // Return the created user with the generated ID
      return UserModel.fromJson({
        ...userData,
        'id': userData['_id'].toHexString(),
      });
    } catch (e) {
      if (e.toString().contains('E11000')) {
        throw ValidationException('Email already exists');
      }
      throw DatabaseException('Failed to create user: $e');
    }
  }

  Future<String?> getPasswordHash(String userId) async {
    try {
      final objectId = ObjectId.parse(userId);
      final result = await _users.findOne(
        where.eq('_id', objectId),
        {'passwordHash': 1},
      );
      
      return result?['passwordHash'] as String?;
    } catch (e) {
      throw DatabaseException('Failed to get password hash: $e');
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      final objectId = ObjectId.parse(userId);
      await _users.updateOne(
        where.eq('_id', objectId),
        modify.set('lastLoginAt', DateTime.now()),
      );
    } catch (e) {
      throw DatabaseException('Failed to update last login: $e');
    }
  }

  Future<TeacherProfile> createTeacherProfile(TeacherProfile profile) async {
    try {
      final profileData = profile.toJson();
      profileData['_id'] = ObjectId();
      profileData['userId'] = ObjectId.parse(profile.user.id);
      profileData['createdAt'] = DateTime.now();
      profileData['updatedAt'] = DateTime.now();

      await _teacherProfiles.insertOne(profileData);
      
      return TeacherProfile.fromJson({
        ...profileData,
        'id': profileData['_id'].toHexString(),
      });
    } catch (e) {
      throw DatabaseException('Failed to create teacher profile: $e');
    }
  }

  Future<StudentProfile> createStudentProfile(StudentProfile profile) async {
    try {
      final profileData = profile.toJson();
      profileData['_id'] = ObjectId();
      profileData['userId'] = ObjectId.parse(profile.user.id);
      profileData['createdAt'] = DateTime.now();
      profileData['updatedAt'] = DateTime.now();

      await _studentProfiles.insertOne(profileData);
      
      return StudentProfile.fromJson({
        ...profileData,
        'id': profileData['_id'].toHexString(),
      });
    } catch (e) {
      throw DatabaseException('Failed to create student profile: $e');
    }
  }

  Future<ParentProfile> createParentProfile(ParentProfile profile) async {
    try {
      final profileData = profile.toJson();
      profileData['_id'] = ObjectId();
      profileData['userId'] = ObjectId.parse(profile.user.id);
      profileData['createdAt'] = DateTime.now();
      profileData['updatedAt'] = DateTime.now();

      await _parentProfiles.insertOne(profileData);
      
      return ParentProfile.fromJson({
        ...profileData,
        'id': profileData['_id'].toHexString(),
      });
    } catch (e) {
      throw DatabaseException('Failed to create parent profile: $e');
    }
  }

  Future<StudentProfile?> findStudentByAdmissionNumber(String admissionNumber) async {
    try {
      final result = await _studentProfiles.findOne(
        where.eq('admissionNumber', admissionNumber)
      );
      if (result == null) return null;
      
      // Get associated user
      final userId = result['userId'] as ObjectId;
      final userResult = await _users.findOne(where.eq('_id', userId));
      if (userResult == null) return null;
      
      final user = UserModel.fromJson({
        ...userResult,
        'id': userResult['_id'].toHexString(),
      });
      
      return StudentProfile.fromJson({
        ...result,
        'id': result['_id'].toHexString(),
        'user': user.toJson(),
      });
    } catch (e) {
      throw DatabaseException('Failed to find student by admission number: $e');
    }
  }

  Future<TeacherProfile?> getTeacherProfile(String userId) async {
    try {
      final objectId = ObjectId.parse(userId);
      final result = await _teacherProfiles.findOne(
        where.eq('userId', objectId)
      );
      if (result == null) return null;
      
      final user = await findById(userId);
      if (user == null) return null;
      
      return TeacherProfile.fromJson({
        ...result,
        'id': result['_id'].toHexString(),
        'user': user.toJson(),
      });
    } catch (e) {
      throw DatabaseException('Failed to get teacher profile: $e');
    }
  }

  Future<StudentProfile?> getStudentProfile(String userId) async {
    try {
      final objectId = ObjectId.parse(userId);
      final result = await _studentProfiles.findOne(
        where.eq('userId', objectId)
      );
      if (result == null) return null;
      
      final user = await findById(userId);
      if (user == null) return null;
      
      return StudentProfile.fromJson({
        ...result,
        'id': result['_id'].toHexString(),
        'user': user.toJson(),
      });
    } catch (e) {
      throw DatabaseException('Failed to get student profile: $e');
    }
  }

  Future<ParentProfile?> getParentProfile(String userId) async {
    try {
      final objectId = ObjectId.parse(userId);
      final result = await _parentProfiles.findOne(
        where.eq('userId', objectId)
      );
      if (result == null) return null;
      
      final user = await findById(userId);
      if (user == null) return null;
      
      return ParentProfile.fromJson({
        ...result,
        'id': result['_id'].toHexString(),
        'user': user.toJson(),
      });
    } catch (e) {
      throw DatabaseException('Failed to get parent profile: $e');
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final objectId = ObjectId.parse(userId);
      updates['updatedAt'] = DateTime.now();
      
      await _users.updateOne(
        where.eq('_id', objectId),
        modify.set(updates.keys.first, updates.values.first)
          ..set('updatedAt', updates['updatedAt']),
      );
      
      final updatedUser = await findById(userId);
      if (updatedUser == null) {
        throw DatabaseException('User not found after update');
      }
      
      return updatedUser;
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }
}
