import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/presentation/providers/auth_provider.dart';
import 'package:workspace_guard/presentation/providers/workspace_state.dart';
import 'package:workspace_guard/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Виносимо логіку показу діалогу в окремий метод для чистоти коду
  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Підтвердження виходу'),
          content: const Text('Ви дійсно хочете вийти з акаунту?'),
          actions: [
            TextButton(
              onPressed: () {
                // Закриваємо діалог і повертаємо false (Ні)
                Navigator.of(context).pop(false);
              },
              child: const Text('Ні'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () {
                // Закриваємо діалог і повертаємо true (Так)
                Navigator.of(context).pop(true);
              },
              child: const Text('Так, вийти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<WorkspaceState>();
    final user = authProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
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
            onPressed: () async {
              // 1. Чекаємо відповіді від користувача з діалогового вікна
              final shouldLogout = await _showLogoutConfirmation(context);

              // 2. Якщо користувач натиснув "Ні" або просто закрив вікно 
              // (shouldLogout == null або false)
              if (shouldLogout != true) return;

              // 3. Якщо користувач натиснув "Так", продовжуємо процес виходу
              if (!context.mounted) return; // Перевірка, чи екран ще існує

              await context.read<AuthProvider>().logout();
              
              if (!context.mounted) return;
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