import 'package:workspace_guard/data/api/api_client.dart';
import 'package:workspace_guard/secrets.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  // Реєстрація нового користувача
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response = await _apiClient.authClient.post<dynamic>(
      'accounts:signUp',
      queryParameters: {'key': Secrets.firebaseWebApiKey},
      data: {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // Вхід у систему
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _apiClient.authClient.post<dynamic>(
      'accounts:signInWithPassword',
      queryParameters: {'key': Secrets.firebaseWebApiKey},
      data: {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
