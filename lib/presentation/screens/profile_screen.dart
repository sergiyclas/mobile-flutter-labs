import 'package:flash_toggle_plugin/flash_toggle_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workspace_guard/presentation/cubits/auth_cubit.dart';
import 'package:workspace_guard/presentation/cubits/mqtt_cubit.dart';
import 'package:workspace_guard/presentation/cubits/navigation_cubit.dart';
import 'package:workspace_guard/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Секретний тригер: подвійний тап по аватару перемикає ліхтарик.
  Future<void> _onSecretFlashTap(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final isOn = await FlashTogglePlugin.toggleLight();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text(isOn ? 'Flashlight ON' : 'Flashlight OFF'),
        ),
      );
    } on UnsupportedError {
      if (!context.mounted) return;
      await _showUnsupportedDialog(context);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to toggle flashlight.')),
      );
    }
  }

  Future<void> _showUnsupportedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Not supported'),
        content: const Text(
          'Flashlight control is available only on Android devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, stay logged in'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final mqttState = context.watch<MqttCubit>().state;
    final user = authState.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onDoubleTap: () => _onSecretFlashTap(context),
            child: const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'user@example.com',
            style: const TextStyle(color: Colors.grey),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: mqttState.notificationsEnabled,
              onChanged: 
                (val) => context.read<MqttCubit>().toggleNotifications(val),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: mqttState.isDarkMode,
              onChanged: (val) => context.read<MqttCubit>().toggleTheme(val),
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
            onPressed: () async {
              final shouldLogout = await _showLogoutConfirmation(context);
              if (shouldLogout != true) return;
              if (!context.mounted) return;

              await context.read<AuthCubit>().logout();
              if (!context.mounted) return;
              
              // Скидаємо вкладку на головну при логауті
              context.read<NavigationCubit>().setTab(0);
              
              await Navigator.pushReplacement(
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
