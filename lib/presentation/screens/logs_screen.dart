import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workspace_guard/presentation/cubits/auth_cubit.dart';
import 'package:workspace_guard/presentation/cubits/logs_cubit.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final uid = context.read<AuthCubit>().state.currentUser?.uid;
              context.read<LogsCubit>().fetchLogs(uid ?? 'unknown');
            },
          ),
        ],
      ),
      body: BlocBuilder<LogsCubit, LogsState>(
        builder: (context, state) {
          if (state.isLoading && state.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          } else if (state.logs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Text('No saved logs.', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final uid = context.read<AuthCubit>().state.currentUser?.uid;
              await context.read<LogsCubit>().fetchLogs(uid ?? 'unknown');
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
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
                    title: Text('Distance: ${log.distance} cm'),
                    subtitle: Text('Time: ${log.timestamp}'),
                    trailing: log.motion
                        ? const Text(
                            'Motion!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            'Quiet',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
