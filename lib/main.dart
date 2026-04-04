import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/data/repositories/local_user_repository.dart';
import 'package:workspace_guard/presentation/providers/auth_provider.dart';
import 'package:workspace_guard/presentation/providers/network_provider.dart';
import 'package:workspace_guard/presentation/providers/workspace_state.dart';
import 'package:workspace_guard/presentation/screens/home_screen.dart';
import 'package:workspace_guard/presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localUserRepository = LocalUserRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceState()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(localUserRepository),
        ),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: Consumer<WorkspaceState>(
        builder: (context, workspaceState, _) {
          return MaterialApp(
            title: 'Workspace Monitor',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: workspaceState.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.currentUser != null) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
