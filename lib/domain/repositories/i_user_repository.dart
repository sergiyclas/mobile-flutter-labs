import 'package:workspace_guard/domain/entities/user_entity.dart';

abstract interface class IUserRepository {
  Future<void> registerUser(UserEntity user);
  Future<UserEntity?> loginUser(String email, String password);
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser();
  Future<void> logoutUser();
}
