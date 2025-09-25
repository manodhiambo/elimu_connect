import 'package:elimuconnect_shared/shared.dart';
import '../repositories/user_repository.dart';
import '../utils/exceptions.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  Future<List<UserModel>> getUsers({
    int page = 1,
    int limit = 20,
    UserRole? role,
  }) async {
    try {
      return await _userRepository.getUsers(
        skip: (page - 1) * limit,
        limit: limit,
        role: role,
      );
    } catch (e) {
      throw DatabaseException('Failed to get users: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _userRepository.findById(userId);
    } catch (e) {
      throw DatabaseException('Failed to get user: $e');
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Remove sensitive fields that shouldn't be updated directly
      updates.remove('password');
      updates.remove('passwordHash');
      updates.remove('role');
      updates.remove('id');
      updates.remove('createdAt');

      return await _userRepository.updateUser(userId, updates);
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
    } catch (e) {
      throw DatabaseException('Failed to delete user: $e');
    }
  }

  Future<dynamic> getUserProfile(String userId) async {
    try {
      final user = await _userRepository.findById(userId);
      if (user == null) return null;

      switch (user.role) {
        case UserRole.teacher:
          return await _userRepository.getTeacherProfile(userId);
        case UserRole.student:
          return await _userRepository.getStudentProfile(userId);
        case UserRole.parent:
          return await _userRepository.getParentProfile(userId);
        case UserRole.admin:
          return user; // Admin doesn't have extended profile for now
      }
    } catch (e) {
      throw DatabaseException('Failed to get user profile: $e');
    }
  }

  Future<List<UserModel>> searchUsers({
    required String query,
    UserRole? role,
    String? schoolId,
  }) async {
    try {
      return await _userRepository.searchUsers(
        query: query,
        role: role,
        schoolId: schoolId,
      );
    } catch (e) {
      throw DatabaseException('Failed to search users: $e');
    }
  }

  Future<List<TeacherProfile>> getTeachers({
    String? schoolId,
    String? subject,
  }) async {
    try {
      return await _userRepository.getTeachers(
        schoolId: schoolId,
        subject: subject,
      );
    } catch (e) {
      throw DatabaseException('Failed to get teachers: $e');
    }
  }

  Future<List<StudentProfile>> getStudents({
    String? schoolId,
    String? className,
  }) async {
    try {
      return await _userRepository.getStudents(
        schoolId: schoolId,
        className: className,
      );
    } catch (e) {
      throw DatabaseException('Failed to get students: $e');
    }
  }

  Future<List<ParentProfile>> getParents({String? schoolId}) async {
    try {
      return await _userRepository.getParents(schoolId: schoolId);
    } catch (e) {
      throw DatabaseException('Failed to get parents: $e');
    }
  }
}
