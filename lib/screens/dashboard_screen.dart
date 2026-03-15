import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/main.dart';
import 'package:workspace_guard/widgets/mini_bar_chart_card.dart';
import 'package:workspace_guard/widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<WorkspaceState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

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
              IconButton(
                icon: Icon(
                  appState.isSimulationRunning
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color:
                      appState.isSimulationRunning
                          ? Colors.orangeAccent
                          : Colors.green,
                  size: 32,
                ),
                onPressed: appState.toggleSimulation,
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
                statusColor:
                    appState.distance < 40 ? Colors.redAccent : Colors.green,
              ),
              SensorCard(
                title: 'Door',
                value: appState.hasMotion ? 'Motion!' : 'Clear',
                icon:
                    appState.hasMotion
                        ? Icons.directions_run
                        : Icons.sensor_door,
                statusColor:
                    appState.hasMotion ? Colors.orangeAccent : Colors.green,
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
            child:
                appState.history.isEmpty
                    ? const Center(
                      child: Text(
                        'History is empty',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: appState.history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.history, size: 20),
                            title: Text(appState.history[index]),
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
