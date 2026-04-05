import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:workspace_guard/data/repositories/logs_repository.dart';
import 'package:workspace_guard/mqtt/mqtt_setup.dart'
    if (dart.library.io) '../../mqtt/mqtt_setup_io.dart'
    if (dart.library.html) '../../mqtt/mqtt_setup_web.dart';

class MqttState {
  final int distance;
  final bool hasMotion;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final List<int> distanceHistory;
  final List<int> motionHistory;
  final List<String> history;
  final bool isMqttConnected;

  const MqttState({
    this.distance = 45,
    this.hasMotion = false,
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.distanceHistory = const [],
    this.motionHistory = const [],
    this.history = const ['System initialized'],
    this.isMqttConnected = false,
  });

  MqttState copyWith({
    int? distance, bool? hasMotion, bool? isDarkMode, bool? notificationsEnabled,
    List<int>? distanceHistory, List<int>? motionHistory,
    List<String>? history, bool? isMqttConnected,
  }) {
    return MqttState(
      distance: distance ?? this.distance,
      hasMotion: hasMotion ?? this.hasMotion,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      distanceHistory: distanceHistory ?? this.distanceHistory,
      motionHistory: motionHistory ?? this.motionHistory,
      history: history ?? this.history,
      isMqttConnected: isMqttConnected ?? this.isMqttConnected,
    );
  }
}

class MqttCubit extends Cubit<MqttState> {
  MqttClient? _client;
  final String broker = 'broker.hivemq.com';
  final String topic = 'workspace_guard/sensor/my_unique_data';
  final LogsRepository _logsRepository;
  String? _currentUserId;

  MqttCubit(this._logsRepository) : super(MqttState(
    distanceHistory: List.filled(12, 45, growable: true),
    motionHistory: List.filled(12, 0, growable: true),
  )) {
    _connectToMqtt();
  }

  void setUserId(String? uid) => _currentUserId = uid;

  void toggleTheme(bool v) => emit(state.copyWith(isDarkMode: v));

  void toggleNotifications(bool v) => emit(state.copyWith(notificationsEnabled: v));

  void clearHistory() => emit(state.copyWith(history: []));

  void resetData() {
    emit(state.copyWith(
      distance: 45, hasMotion: false,
      distanceHistory: List.filled(12, 45, growable: true),
      motionHistory: List.filled(12, 0, growable: true),
      history: ['System initialized'],
    ));
  }

  Future<void> _connectToMqtt() async {
    final cid = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    _client = getMqttClient(broker, cid)
      ..logging(on: false)..keepAlivePeriod = 20
      ..onDisconnected = _onDisconnected
      ..connectionMessage = MqttConnectMessage()
          .startClean().withWillQos(MqttQos.atMostOnce);

    try {
      _addLog('Connecting to MQTT...');
      await _client!.connect();
    } catch (e) {
      _addLog('MQTT Connection failed: $e');
      _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      emit(state.copyWith(isMqttConnected: true));
      _addLog('Connected to MQTT Broker!');
      _client!.subscribe(topic, MqttQos.atMostOnce);
      _client!.updates!.listen((c) {
        final recMess = c[0].payload as MqttPublishMessage;
        _processMqttMessage(
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message)
        );
      });
    }
  }

  String get _time {
    final n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.hour}:${p(n.minute)}:${p(n.second)}';
  }

  List<int> _updateHist(List<int> h, int v) {
    final newHist = List<int>.from(h)..add(v);
    if (newHist.length > 12) newHist.removeAt(0);
    return newHist;
  }

  void _processMqttMessage(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      int newDist = state.distance;
      bool newMotion = state.hasMotion;
      List<int> newDistHist = state.distanceHistory;
      List<int> newMotionHist = state.motionHistory;

      if (data.containsKey('distance')) {
        newDist = (data['distance'] as num).toInt();
        newDistHist = _updateHist(state.distanceHistory, newDist);
      }
      if (data.containsKey('motion')) {
        newMotion = data['motion'] == true || data['motion'] == 1;
        newMotionHist = _updateHist(state.motionHistory, newMotion ? 1 : 0);
      }

      if (_currentUserId != null) {
        _logsRepository.addLog(_currentUserId!, LogModel(
          id: '', distance: newDist, motion: newMotion, timestamp: _time,
        ));
      }

      emit(state.copyWith(
        distance: newDist, hasMotion: newMotion,
        distanceHistory: newDistHist, motionHistory: newMotionHist,
      ));

      if (state.notificationsEnabled) {
        if (newDist < 40) _addLog('Too close to screen: $newDist cm!');
        if (newMotion) _addLog('Motion detected at the door!');
      }
    } catch (e) { _addLog('Error parsing MQTT data: $e'); }
  }

  void _onDisconnected() {
    emit(state.copyWith(isMqttConnected: false));
    _addLog('Disconnected from MQTT');
  }

  void _addLog(String msg) {
    final newHist = List<String>.from(state.history)..insert(0, '$_time - $msg');
    if (newHist.length > 20) newHist.removeLast();
    emit(state.copyWith(history: newHist));
  }

  @override
  Future<void> close() {
    _client?.disconnect();
    return super.close();
  }
}
