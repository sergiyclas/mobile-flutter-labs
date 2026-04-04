import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_guard/secrets.dart'; 

class ApiClient {
  final Dio dbClient;
  final Dio authClient;

  static const String _authBaseUrl = 'https://identitytoolkit.googleapis.com/v1/';

  ApiClient()
      : dbClient = Dio(BaseOptions(baseUrl: Secrets.firebaseDbUrl)),
        authClient = Dio(BaseOptions(baseUrl: _authBaseUrl)) {
    
    dbClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.queryParameters['auth'] = token;
          }
          
          return handler.next(options);
        },
      ),
    );
  }
}
