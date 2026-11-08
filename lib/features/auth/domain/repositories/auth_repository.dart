import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? companyName,
    String? departmentId,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserProfile(UserEntity user);
}
