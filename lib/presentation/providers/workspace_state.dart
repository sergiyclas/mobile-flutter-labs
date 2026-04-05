import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:workspace_guard/data/api/api_client.dart';
import 'package:workspace_guard/data/repositories/logs_repository.dart';
import 'package:workspace_guard/mqtt/mqtt_setup.dart'
    if (dart.library.io) '../../mqtt/mqtt_setup_io.dart'
    if (dart.library.html) '../../mqtt/mqtt_setup_web.dart';

class WorkspaceState extends ChangeNotifier {
  int distance = 45;
  bool hasMotion = false, isDarkMode = true, notificationsEnabled = true;
  List<int> distanceHistory = List.filled(12, 45, growable: true);
  List<int> motionHistory = List.filled(12, 0, growable: true);
  List<String> history = ['System initialized'];
  MqttClient? _client;
  bool isMqttConnected = false;
  final String broker = 'broker.hivemq.com';
  final String topic = 'workspace_guard/sensor/my_unique_data'; 
  late final LogsRepository _logsRepository;
  String? _currentUserId;

  WorkspaceState() {
    _logsRepository = LogsRepository(ApiClient());
    _connectToMqtt();
  }

  void setUserId(String? uid) => _currentUserId = uid;

  void toggleTheme(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  void resetData() {
    distance = 45;
    hasMotion = false;
    distanceHistory = List.filled(12, 45, growable: true);
    motionHistory = List.filled(12, 0, growable: true);
    history = ['System initialized'];
    notifyListeners();
  }

  Future<void> _connectToMqtt() async {
    final clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    
    _client = getMqttClient(broker, clientId)
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..onDisconnected = _onDisconnected
      ..connectionMessage = MqttConnectMessage()
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

    try {
      _addLog('Connecting to MQTT broker...');
      await _client!.connect();
    } catch (e) {
      _addLog('MQTT Connection failed: $e');
      _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      isMqttConnected = true;
      _addLog('Connected to MQTT Broker!');
      notifyListeners();

      _client!.subscribe(topic, MqttQos.atMostOnce);
      _client!.updates!.listen((c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        _processMqttMessage(payload);
      });
    }
  }

  void _processMqttMessage(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      if (data.containsKey('distance')) {
        distance = (data['distance'] as num).toInt();
        distanceHistory.add(distance);
        if (distanceHistory.length > 12) distanceHistory.removeAt(0);
      }
      
      if (data.containsKey('motion')) {
        hasMotion = data['motion'] == true || data['motion'] == 1;
        motionHistory.add(hasMotion ? 1 : 0);
        if (motionHistory.length > 12) motionHistory.removeAt(0);
      }

      final now = DateTime.now();
      final min = now.minute.toString().padLeft(2, '0');
      final sec = now.second.toString().padLeft(2, '0');
      final time = '${now.hour}:$min:$sec';

      if (_currentUserId != null) {
        _logsRepository.addLog(
          _currentUserId!,
          LogModel(
            id: '', distance: distance, motion: hasMotion, timestamp: time,
          ),
        );
      }

      if (notificationsEnabled) {
        if (distance < 40) _addLog('Too close to screen: $distance cm!');
        if (hasMotion) _addLog('Motion detected at the door!');
      }

      notifyListeners();
    } catch (e) { _addLog('Error parsing MQTT data: $e'); }
  }

  void _onDisconnected() {
    isMqttConnected = false;
    _addLog('Disconnected from MQTT');
    notifyListeners();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    history.insert(0, '${now.hour}:$min:$sec - $message');
    if (history.length > 20) history.removeLast();
  }

  @override
  void dispose() {
    _client?.disconnect();
    super.dispose();
  }
}
