import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/data/api/api_client.dart';
import 'package:workspace_guard/data/repositories/logs_repository.dart';
import 'package:workspace_guard/presentation/providers/auth_provider.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late Future<List<LogModel>> _logsFuture;
  late LogsRepository _logsRepository;

  @override
  void initState() {
    super.initState();
    
    // Отримуємо UID поточного користувача
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? 'unknown';

    final apiClient = ApiClient();
    _logsRepository = LogsRepository(apiClient);
    
    // Завантажуємо логи саме для цього юзера
    _logsFuture = _logsRepository.getLogs(userId);
  }

  Future<void> _refreshLogs() async {
    // При оновленні також беремо актуальний UID
    final userId = context.read<AuthProvider>().currentUser?.uid ?? 'unknown';
    
    setState(() {
      _logsFuture = _logsRepository.getLogs(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія спрацювань датчика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLogs,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLogs,
        child: FutureBuilder<List<LogModel>>(
          future: _logsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Помилка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Немає збережених логів.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            }

            final logs = snapshot.data!;
            
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Icon(
                      log.motion ? Icons.directions_run : Icons.pan_tool,
                      color: log.motion ? Colors.redAccent : Colors.green,
                      size: 32,
                    ),
                    title: Text('Відстань: ${log.distance} см'),
                    subtitle: Text('Час: ${log.timestamp}'),
                    trailing: log.motion 
                        ? const Text(
                            'Рух!', 
                            style: TextStyle(
                              color: Colors.red, 
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            'Тихо', 
                            style: TextStyle(color: Colors.grey),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
