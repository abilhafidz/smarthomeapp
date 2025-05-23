
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  Function(bool)? onConnectionChanged; // Callback to notify connection state changes
  Function(String, String)? onMessageReceived; // Callback to notify topic and message received

  MqttService() {
    client = MqttServerClient('178.128.89.8', 'FlutterClient');
    client.port = 1883;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> connect() async {
    final connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier("FlutterClient")
        .withWillTopic("willtopic")
        .withWillMessage("My will message")
        .startClean()
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      print('Connected');
      _notifyConnectionStatus(true);
      client.updates!.listen(_onMessage); // Listen to messages from the broker
    } else {
      print('Connection failed');
      client.disconnect();
      _notifyConnectionStatus(false);
    }
  }

  void _onMessage(List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> event) {
    final mqtt.MqttPublishMessage recMess = event[0].payload as mqtt.MqttPublishMessage;
    final String message = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final String topic = event[0].topic;
    print('Received message: $message from topic: $topic');

    // Notify that a message is received, including both topic and message
    if (onMessageReceived != null) {
      onMessageReceived!(topic, message);
    }
  }

  void _notifyConnectionStatus(bool isConnected) {
    if (onConnectionChanged != null) {
      onConnectionChanged!(isConnected);
    }
  }

  void _onConnected() {
    print('MQTT Connected');
    _notifyConnectionStatus(true);
    subscribe('smarthouse/lamp');
    subscribe('smarthouse/mq');

    void publish(String topic, String message) {
      print('Current connection status: ${client.connectionStatus!.state}');
      if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
        final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
        builder.addString(message);
        client.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!);
        print('Published message: $message to topic: $topic');
      } else {
        print('Cannot publish, not connected');
      }
    }



  }

  void _onDisconnected() {
    print('MQTT Disconnected');
    _notifyConnectionStatus(false);
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
    subscribe('smarthouse/lamp');
    subscribe('smarthouse/mq');


  }

  void subscribe(String topic) {
    if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
      print('mqtt bagian subs berkerja');

    } else {
      print('Cannot subscribe, not connected');
    }
  }
  void publish(String topic, String message) {
    print('Current connection status: ${client.connectionStatus!.state}');
    if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!);
      print('Published message: $message to topic: $topic');
    } else {
      print('Cannot publish, not connected');
    }
  }

  void disconnect() {
    client.disconnect();
  }
}
