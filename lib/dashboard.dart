import 'package:flutter/material.dart';
import 'user_page.dart';
import 'mqtt_service.dart';
import 'package:provider/provider.dart';
import 'switch_state.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'weather.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();

}

class _DashboardPageState extends State<DashboardPage> {
  String _ldrStatus = "Lampu Dimatikan";
  String _h2Status = "Tidak Ada Asap Terdeteksi";
  String _mqttStatus = "Terputus";
  late MqttService _mqttService;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService();
    _mqttService.connect();

    // Subscribe to the required topics
    _mqttService.subscribe("smarthouse/lamp");
    _mqttService.subscribe("smarthouse/mq");

    // Handle connection status updates
    _mqttService.onConnectionChanged = (bool isConnected) {
      setState(() {
        _mqttStatus = isConnected ? "Terhubung" : "Terputus";
      });
    };

    // Handle incoming MQTT messages
    _mqttService.onMessageReceived = (String topic, String message) {
      switch (topic) {
        case "smarthouse/lamp":
          _updateLDRStatus(message);
          break;
        case "smarthouse/mq":
          _updateH2Status(message);
          break;
        default:
          print("Received message from unknown topic: $topic");
      }
    };
  }






  void _onItemTapped(int index) {
    Widget page;

    switch (index) {
      case 0:
        return;
      case 1:
        page = WeatherPage();
        break;
      case 2:
        page = UserPage();
        break;
      default:
        return;
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



  void _toggleServo(bool value) {
    if (_mqttService.client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      if (value) {
        _mqttService.publish('smarthouse/servo', 'open');
        Provider.of<SwitchState>(context, listen: false).toggleServo(true);
      } else {
        _mqttService.publish('smarthouse/servo', 'close');
        Provider.of<SwitchState>(context, listen: false).toggleServo(false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi MQTT belum terhubung')),
      );
    }
  }




  void _updateLDRStatus(String message) {
    setState(() {
      _ldrStatus = (message == "Lampu Menyala") ? "Lampu Menyala" : "Lampu Dimatikan";
    });
  }

  void _updateH2Status(String message) {
    setState(() {
      _h2Status= (message == "Asap Terdeteksi") ? "Asap Terdeteksi" : "Tidak Ada Asap Terdeteksi";
    });
  }
  @override
  Widget build(BuildContext context) {
    final switchState = Provider.of<SwitchState>(context);

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
              'Dashboard',
              style: TextStyle(
                color: Color(0xFF66544D),
                fontFamily: 'Unica One',
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
                            leading: Icon(Icons.door_sliding, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Kontrol Pintu',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,  fontFamily: 'Unica One',),
                            ),
                            trailing: Switch(
                              activeColor: Color(0xFF5B4741),
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
                            leading: Icon(Icons.lightbulb, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Status Lampu',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,  fontFamily: 'Unica One',),
                            ),
                            subtitle: Text(
                              _ldrStatus,
                              style: TextStyle(fontSize: 18,fontFamily: 'Unica One'),
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
                            leading: Image.asset(
                              'assets/images/detector_smoke.png',
                              width: 40,
                              height: 40,
                              color: Color(0xFF5B4741),
                            ),
                            title: Text(
                              'Sensor Asap',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Unica One'),
                            ),
                            subtitle: Text(
                              _h2Status,
                              style: TextStyle(fontSize: 18, fontFamily: 'Unica One'),
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
                            leading: Icon(Icons.network_check, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Status Koneksi MQTT',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: 'Unica One',),
                            ),
                            subtitle: Text(
                              _mqttStatus,
                              style: TextStyle(fontSize: 18,fontFamily: 'Unica One',),
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
            icon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Unica One',

        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Unica One',

        ),
        onTap: _onItemTapped,

      ),
    );
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }
}