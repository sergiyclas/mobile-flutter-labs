import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_guard/domain/entities/user_entity.dart';
import 'package:workspace_guard/domain/repositories/i_user_repository.dart';

class LocalUserRepository implements IUserRepository {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<void> registerUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userDataString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userDataString);
  }

  @override
  Future<UserEntity?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString(_userKey);

    if (userDataString != null) {
      final dynamic decodedData = jsonDecode(userDataString);
      final Map<String, dynamic> userData =
          decodedData as Map<String, dynamic>;
      final user = UserEntity.fromJson(userData);

      if (user.email == email && user.password == password) {
        await prefs.setBool(_isLoggedInKey, true);
        return user;
      }
    }
    return null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (isLoggedIn) {
      final String? userDataString = prefs.getString(_userKey);
      if (userDataString != null) {
        final dynamic decodedData = jsonDecode(userDataString);
        final Map<String, dynamic> userData =
            decodedData as Map<String, dynamic>;
        return UserEntity.fromJson(userData);
      }
    }
    return null;
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userDataString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userDataString);
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
  }

  @override
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }
}
