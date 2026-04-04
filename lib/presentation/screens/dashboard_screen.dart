import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/presentation/providers/workspace_state.dart';
import 'package:workspace_guard/presentation/widgets/mini_bar_chart_card.dart';
import 'package:workspace_guard/presentation/widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<WorkspaceState>();
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sensors Status',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Icon(
                appState.isMqttConnected ? Icons.wifi : Icons.wifi_off,
                color: appState.isMqttConnected
                    ? Colors.green
                    : Colors.redAccent,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SensorCard(
                title: 'Distance',
                value: '${appState.distance} cm',
                icon: Icons.computer,
                statusColor: appState.distance < 40
                    ? Colors.redAccent
                    : Colors.green,
              ),
              SensorCard(
                title: 'Door',
                value: appState.hasMotion ? 'Motion!' : 'Clear',
                icon: appState.hasMotion
                    ? Icons.directions_run
                    : Icons.sensor_door,
                statusColor: appState.hasMotion
                    ? Colors.orangeAccent
                    : Colors.green,
              ),
              MiniBarChartCard(
                title: 'Distance Graph',
                subtitle: 'Last 12 readings (cm)',
                data: appState.distanceHistory,
                maxValue: 80,
                barColor: Colors.blueAccent,
              ),
              MiniBarChartCard(
                title: 'Door Activity',
                subtitle: '0 = Clear, 1 = Motion',
                data: appState.motionHistory,
                maxValue: 1,
                barColor: Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Events',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: appState.clearHistory,
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: appState.history.length,
              itemBuilder: (context, index) {
                final logMsg = appState.history[index];
                final isWarning = logMsg.contains('Too close');
                final isMotion = logMsg.contains('Motion');
                
                final color = isWarning
                    ? Colors.redAccent
                    : (isMotion ? Colors.orangeAccent : Colors.blueAccent);
                
                final icon = isWarning
                    ? Icons.warning
                    : (isMotion ? Icons.directions_run : Icons.info);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: color, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            logMsg,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
