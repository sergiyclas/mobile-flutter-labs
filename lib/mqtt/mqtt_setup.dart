import 'package:mqtt_client/mqtt_client.dart';

// Ця функція ніколи не викличеться напряму, вона потрібна як "шаблон"
MqttClient getMqttClient(String broker, String clientId) {
  throw UnsupportedError(
      'Cannot create an MQTT client without a specific platform implementation'
    );
}
