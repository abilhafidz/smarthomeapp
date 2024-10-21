import 'package:flutter/material.dart';
import 'user_page.dart'; // Import UserPage
import 'mqtt_service.dart'; // Import MQTT service
import 'package:provider/provider.dart';
import 'switch_state.dart'; // Import SwitchState model
import 'package:mqtt_client/mqtt_client.dart' as mqtt; // Import mqtt_client dengan alias mqtt
import 'weather.dart'; // Import WeatherPage

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _ldrStatus = "Lampu Dimatikan"; // Status for LDR
  String _mqttStatus = "Terputus"; // Status for MQTT connection
  late MqttService _mqttService; // Declare MQTT service

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService(); // Initialize MQTT service
    _mqttService.connect(); // Connect to the MQTT broker
    _mqttService.subscribe("smarthouse/lamp"); // Subscribe to LDR status

    // Update MQTT status based on connection state
    _mqttService.onConnectionChanged = (bool isConnected) {
      setState(() {
        _mqttStatus = isConnected ? "Terhubung" : "Terputus";
      });
    };
  }

  void _onItemTapped(int index) {
    Widget page;

    switch (index) {
      case 0: // Dashboard
        return; // Tidak perlu melakukan apa-apa jika dashboard sudah dipilih
      case 1: // Weather Page
        page = WeatherPage();
        break;
      case 2: // User Page
        page = UserPage();
        break;
      default:
        return; // Tidak perlu melakukan apa-apa jika tidak ada halaman yang valid
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = 0.0;
          var end = 1.0;
          var curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var opacityAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: opacityAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  // Function to control the servo and send command via MQTT
  void _toggleServo(bool value) {
    if (_mqttService.client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      if (value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String pin = "";
            return AlertDialog(
              title: Text('Masukkan PIN'),
              content: TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: "Masukkan PIN"),
                onChanged: (value) {
                  pin = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Kirim'),
                  onPressed: () {
                    if (pin == "123") {
                      _mqttService.publish('smarthouse/servo', 'open');
                      Provider.of<SwitchState>(context, listen: false).toggleServo(true);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PIN salah!')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      } else {
        Provider.of<SwitchState>(context, listen: false).toggleServo(false);
        _mqttService.publish('smarthouse/servo', 'close');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi MQTT belum terhubung')),
      );
    }
  }

  // Function to control the buzzer and send command via MQTT
  void _toggleBuzzer(bool value) {
    if (_mqttService.client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      if (value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String description = "";
            return AlertDialog(
              title: Text('Deskripsi Peringatan'),
              content: TextField(
                decoration: InputDecoration(hintText: "Masukkan deskripsi peringatan"),
                onChanged: (value) {
                  description = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Kirim'),
                  onPressed: () {
                    _mqttService.publish('smarthouse/buzzer', 'on: $description');
                    Provider.of<SwitchState>(context, listen: false).toggleBuzzer(true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        Provider.of<SwitchState>(context, listen: false).toggleBuzzer(false);
        _mqttService.publish('smarthouse/buzzer', 'off');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi MQTT belum terhubung')),
      );
    }
  }

  // Simulated LDR status update
  void _updateLDRStatus(String status) {
    setState(() {
      _ldrStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final switchState = Provider.of<SwitchState>(context); // Get the SwitchState

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Color(0xFFFAEBD7),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF5B4741),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 70,
                height: 70,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo_rumah.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              'DASHBOARD',
              style: TextStyle(
                color: Color(0xFF66544D),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF5B4741),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.door_sliding, size: 40, color: Colors.green),
                            title: Text(
                              'Kontrol Pintu',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            trailing: Switch(
                              activeColor: Colors.green,
                              value: switchState.servoState,
                              onChanged: (value) {
                                _toggleServo(value);
                              },
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.lightbulb, size: 40, color: Colors.yellow[700]),
                            title: Text(
                              'Status Lampu',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _ldrStatus,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.notifications, size: 40, color: Colors.red),
                            title: Text(
                              'Peringatan Alarm',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            trailing: Switch(
                              activeColor: Colors.red,
                              value: switchState.buzzerState,
                              onChanged: (value) {
                                _toggleBuzzer(value);
                              },
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.network_check, size: 40, color: Colors.blue),
                            title: Text(
                              'Status Koneksi MQTT',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _mqttStatus,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFAEBD7),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny), // Icon for Weather
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: 0, // Set current index to 0 for the Dashboard
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _mqttService.disconnect(); // Disconnect the MQTT service when disposing
    super.dispose();
  }
}