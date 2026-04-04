import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient getMqttClient(String broker, String clientId) {
  // Для вебу ми додаємо ws:// і змінюємо порт на 8000
  final client = MqttBrowserClient('ws://$broker/mqtt', clientId);
  client.port = 8000;
  // Специфічне налаштування для браузера
  client.setProtocolV311();
  return client;
}
