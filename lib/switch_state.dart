import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mqtt_service.dart'; // Ensure this path is correct according to your folder structure

class SwitchState with ChangeNotifier {
  bool _servoState = false;
  bool _buzzerState = false;
  final MqttService mqttService; // Change to public

  SwitchState(this.mqttService) { // Update constructor
    mqttService.onConnectionChanged = _updateConnectionStatus; // Set callback
    _loadSwitchStates(); // Load saved states when initialized
  }

  bool get servoState => _servoState;
  bool get buzzerState => _buzzerState;

  void toggleServo(bool value) {
    _servoState = value;
    _saveSwitchState('servo', value); // Save state to shared preferences
    _publishStatus(); // Publish current status to MQTT
    notifyListeners();
  }

  void toggleBuzzer(bool value) {
    _buzzerState = value;
    _saveSwitchState('buzzer', value); // Save state to shared preferences
    _publishStatus(); // Publish current status to MQTT
    notifyListeners();
  }

  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    _servoState = prefs.getBool('servo') ?? false; // Load saved state or default to false
    _buzzerState = prefs.getBool('buzzer') ?? false; // Load saved state or default to false
    notifyListeners(); // Notify listeners to update UI
  }

  void _publishStatus() {
    // Call publish method from MqttService here
    mqttService.publish('smarthouse/servo', _servoState ? 'on' : 'off');
    mqttService.publish('smarthouse/buzzer', _buzzerState ? 'on' : 'off');
  }

  void _updateConnectionStatus(bool isConnected) {
    // Handle the connection status update
    if (isConnected) {
      print('MQTT Connected');
    } else {
      print('MQTT Disconnected');
    }
  }
}
