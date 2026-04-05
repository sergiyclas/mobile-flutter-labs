import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workspace_guard/presentation/cubits/auth_cubit.dart';
import 'package:workspace_guard/presentation/cubits/logs_cubit.dart';
import 'package:workspace_guard/presentation/cubits/network_cubit.dart';
import 'package:workspace_guard/presentation/cubits/mqtt_cubit.dart';
import 'package:workspace_guard/presentation/cubits/navigation_cubit.dart';
import 'package:workspace_guard/presentation/screens/dashboard_screen.dart';
import 'package:workspace_guard/presentation/screens/logs_screen.dart';
import 'package:workspace_guard/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Встановлюємо UID одразу при побудові
    final uid = context.read<AuthCubit>().state.currentUser?.uid;
    context.read<MqttCubit>().setUserId(uid);

    final isConnected = context.watch<NetworkCubit>().state;
    final selectedIndex = context.watch<NavigationCubit>().state;

    Widget page;
    switch (selectedIndex) {
      case 0: page = const DashboardScreen(); break;
      case 1: page = const LogsScreen(); break;
      case 2: page = const ProfileScreen(); break;
      default: throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!isConnected)
              Container(
                width: double.infinity, color: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  'No Internet Connection! Working in offline mode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            Expanded(child: page),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 1) {
            context.read<LogsCubit>().fetchLogs(uid ?? 'unknown');
          }
          context.read<NavigationCubit>().setTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), 
            label: 'Dashboard',),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
