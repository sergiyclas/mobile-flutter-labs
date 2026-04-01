import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

// --- МАГІЯ УМОВНИХ ІМПОРТІВ ---
// За замовчуванням імпортуємо пустушку...
import '../../mqtt/mqtt_setup.dart'
// ...але якщо ми на телефоні (є бібліотека io), беремо цей файл:
    if (dart.library.io) '../../mqtt/mqtt_setup_io.dart'
// ...або якщо ми в браузері (є бібліотека html), беремо цей:
    if (dart.library.html) '../../mqtt/mqtt_setup_web.dart';

class WorkspaceState extends ChangeNotifier {
  int distance = 45;
  bool hasMotion = false;

  List<int> distanceHistory = <int>[...List.filled(12, 45)];
  List<int> motionHistory = <int>[...List.filled(12, 0)];
  List<String> history = ['System initialized'];

  bool isDarkMode = true;
  bool notificationsEnabled = true;

  // Використовуємо БАЗОВИЙ клас, який підходить і для вебу, і для мобілки
  MqttClient? _client;
  bool isMqttConnected = false;
  
  // Базова адреса брокера (без ws://)
  final String broker = 'broker.hivemq.com';
  final String topic = 'workspace_guard/sensor/my_unique_data'; 

  WorkspaceState() {
    _connectToMqtt();
  }

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

  Future<void> _connectToMqtt() async {
    final clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    
    // Викликаємо нашу функцію з умовного імпорту. 
    // Вона сама вирішить, який клієнт нам повернути!
    _client = getMqttClient(broker, clientId);
    
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;

    final connMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;

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

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        _processMqttMessage(payload);
      });
    }
  }

  void _processMqttMessage(String payload) {
    try {
      // 1. Явно вказуємо, що ми очікуємо отримати словник (Map)
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Тепер data.containsKey() точно повертає bool, і перша помилка зникає
      if (data.containsKey('distance')) {
        // 2. Явно кажемо, що значення - це число (num), а потім робимо toInt()
        distance = (data['distance'] as num).toInt();
        
        distanceHistory.add(distance);
        if (distanceHistory.length > 12) distanceHistory.removeAt(0);
      }
      
      if (data.containsKey('motion')) {
        hasMotion = data['motion'] == true || data['motion'] == 1;
        motionHistory.add(hasMotion ? 1 : 0);
        if (motionHistory.length > 12) motionHistory.removeAt(0);
      }

      if (notificationsEnabled) {
        if (distance < 40) _addLog('Too close to the screen: $distance cm!');
        if (hasMotion) _addLog('Motion detected at the door!');
      }

      notifyListeners();
    } catch (e) {
      _addLog('Error parsing MQTT data: $e');
      // Додав $e, щоб бачити причину, якщо JSON кривий
    }
  }

  void _onDisconnected() {
    isMqttConnected = false;
    _addLog('Disconnected from MQTT');
    notifyListeners();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    history.insert(0, '$time - $message');
    if (history.length > 20) history.removeLast();
  }

  @override
  void dispose() {
    _client?.disconnect();
    super.dispose();
  }
}
