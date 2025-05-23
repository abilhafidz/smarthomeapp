import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mqtt_service.dart';

class SwitchState with ChangeNotifier {
  bool _servoState = false;
  String _lampStatus = 'off'; // State untuk lampu
  final MqttService mqttService;

  SwitchState(this.mqttService) {
    mqttService.onConnectionChanged = _updateConnectionStatus;
    mqttService.onMessageReceived = _handleMessage; // Tambahkan listener untuk pesan
    _loadSwitchStates();
  }

  bool get servoState => _servoState;
  String get lampStatus => _lampStatus; // Getter untuk status lampu

  void toggleServo(bool value) {
    _servoState = value;
    _saveSwitchState('servo', value);
    _publishStatus();
    notifyListeners();
  }

  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    _servoState = prefs.getBool('servo') ?? false;
    notifyListeners();
  }

  void _publishStatus() {
    mqttService.publish('smarthouse/servo', _servoState ? 'on' : 'off');
  }

  void _updateConnectionStatus(bool isConnected) {
    if (isConnected) {
      print('MQTT Connected');
    } else {
      print('MQTT Disconnected');
    }
  }

  void _handleMessage(String topic, String message) {
    // Menangani pesan yang diterima
    if (topic == 'smarthouse/lamp') {
      _lampStatus = message; // Update status lampu
      notifyListeners(); // Memberitahu listener tentang perubahan
    }
    // Tambahkan logika lain jika ada topik lain yang ingin ditangani
  }
}
