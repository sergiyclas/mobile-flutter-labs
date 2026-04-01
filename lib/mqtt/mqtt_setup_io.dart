import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient getMqttClient(String broker, String clientId) {
  // Для телефону використовуємо звичайну адресу і стандартний TCP-порт
  final client = MqttServerClient(broker, clientId);
  client.port = 1883;
  return client;
}