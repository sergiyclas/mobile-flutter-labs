import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workspace_guard/data/api/api_client.dart';
import 'package:workspace_guard/data/repositories/auth_repository.dart';
import 'package:workspace_guard/data/repositories/local_user_repository.dart';
import 'package:workspace_guard/data/repositories/logs_repository.dart';
import 'package:workspace_guard/presentation/cubits/auth_cubit.dart';
import 'package:workspace_guard/presentation/cubits/logs_cubit.dart';
import 'package:workspace_guard/presentation/cubits/mqtt_cubit.dart';
import 'package:workspace_guard/presentation/cubits/navigation_cubit.dart';
import 'package:workspace_guard/presentation/cubits/network_cubit.dart';
import 'package:workspace_guard/presentation/screens/home_screen.dart';
import 'package:workspace_guard/presentation/screens/login_screen.dart';

void main() {
  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);
  final logsRepository = LogsRepository(apiClient);
  final localUserRepository = LocalUserRepository();

  runApp(
    MyApp(
      authRepository: authRepository,
      logsRepository: logsRepository,
      localUserRepository: localUserRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LogsRepository logsRepository;
  final LocalUserRepository localUserRepository;

  const MyApp({
    required this.authRepository, required this.logsRepository,
    required this.localUserRepository, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: logsRepository),
        RepositoryProvider.value(value: localUserRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(
            userRepository: context.read<LocalUserRepository>(),
            authRepository: context.read<AuthRepository>(),
          )),
          BlocProvider(create: (_) => NetworkCubit()),
          BlocProvider(create: (context) => 
            LogsCubit(context.read<LogsRepository>())),
          BlocProvider(create: (context) => 
            MqttCubit(context.read<LogsRepository>())),
          BlocProvider(create: (_) => NavigationCubit()),
        ],
        child: BlocBuilder<MqttCubit, MqttState>(
          builder: (context, mqttState) {
            return MaterialApp(
              title: 'Workspace Monitor',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blueGrey, brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: 
                mqttState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.currentUser != null) {
                    return const HomeScreen();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
