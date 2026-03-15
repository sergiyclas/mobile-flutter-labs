import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/main.dart';
import 'package:workspace_guard/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<WorkspaceState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          const Text(
            'User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('user@iot-lab.com', style: TextStyle(color: Colors.grey)),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: appState.notificationsEnabled,
              onChanged: appState.toggleNotifications,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: appState.toggleTheme,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
