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
  final bool hasMotion, isDarkMode, notificationsEnabled, isMqttConnected;
  final List<int> distanceHistory, motionHistory;
  final List<String> history;
  const MqttState({
    this.distance = 45, this.hasMotion = false,
    this.isDarkMode = true, this.notificationsEnabled = true,
    this.distanceHistory = const [], this.motionHistory = const [],
    this.history = const ['System initialized'], this.isMqttConnected = false,
  });

  MqttState copyWith({
    int? dist, bool? motion, bool? dark, bool? notif,
    List<int>? distHist, List<int>? motionHist,
    List<String>? hist, bool? connected,
  }) {
    return MqttState(
      distance: dist ?? distance,
      hasMotion: motion ?? hasMotion,
      isDarkMode: dark ?? isDarkMode,
      notificationsEnabled: notif ?? notificationsEnabled,
      distanceHistory: distHist ?? distanceHistory,
      motionHistory: motionHist ?? motionHistory,
      history: hist ?? history,
      isMqttConnected: connected ?? isMqttConnected,
    );
  }
}

class MqttCubit extends Cubit<MqttState> {
  MqttClient? _client;
  final LogsRepository _logsRepository;
  String? _uid;

  MqttCubit(this._logsRepository) : super(MqttState(
    distanceHistory: List.filled(12, 45, growable: true),
    motionHistory: List.filled(12, 0, growable: true),
  )) { _connectToMqtt(); }

  void setUserId(String? uid) => _uid = uid;
  void toggleTheme(bool v) => emit(state.copyWith(dark: v));
  void toggleNotifications(bool v) => emit(state.copyWith(notif: v));
  void clearHistory() => emit(state.copyWith(hist: []));

  void resetData() {
    emit(state.copyWith(
      dist: 45, motion: false, hist: ['System initialized'],
      distHist: List.filled(12, 45, growable: true),
      motionHist: List.filled(12, 0, growable: true),
    ));
  }

  Future<void> _connectToMqtt() async {
    final cid = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    _client = getMqttClient('broker.hivemq.com', cid)
      ..logging(on: false)..keepAlivePeriod = 20
      ..onDisconnected = () {emit(state.copyWith(connected: false));
        _addLog('Disconnected from MQTT');
      }
      ..connectionMessage = MqttConnectMessage()
          .startClean().withWillQos(MqttQos.atMostOnce);

    try {
      _addLog('Connecting to MQTT...'); await _client!.connect();
    } catch (e) {
      _addLog('MQTT Connection failed: $e'); _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      emit(state.copyWith(connected: true));
      _addLog('Connected to MQTT Broker!');
      _client!.subscribe(
        'workspace_guard/sensor/my_unique_data', MqttQos.atMostOnce,
      );
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
      int d = state.distance; bool m = state.hasMotion;
      List<int> dH = state.distanceHistory; List<int> mH = state.motionHistory;

      if (data.containsKey('distance')) {
        d = (data['distance'] as num).toInt();
        dH = _updateHist(state.distanceHistory, d);
      }
      if (data.containsKey('motion')) {
        m = data['motion'] == true || data['motion'] == 1;
        mH = _updateHist(state.motionHistory, m ? 1 : 0);
      }

      if (_uid != null) {
        _logsRepository.addLog(_uid!, LogModel(
          id: '', distance: d, motion: m, timestamp: _time,
        ));
      }

      emit(state.copyWith(dist: d, motion: m, distHist: dH, motionHist: mH));

      if (state.notificationsEnabled) {
        if (d < 40) _addLog('Too close to screen: $d cm!');
        if (m) _addLog('Motion detected at the door!');
      }
    } catch (e) { _addLog('Error parsing MQTT data: $e'); }
  }

  void _addLog(String msg) {
    final newHist = 
      List<String>.from(state.history)..insert(0, '$_time - $msg');
    if (newHist.length > 20) newHist.removeLast();
    emit(state.copyWith(hist: newHist));
  }

  @override
  Future<void> close() {
    _client?.disconnect();
    return super.close();
  }
}
