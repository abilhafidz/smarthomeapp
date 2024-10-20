import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'switch_state.dart';
import 'package:provider/provider.dart';
import 'user_page.dart';
import 'dashboard.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _weatherInfo = "Loading...";
  String _earthquakeInfo = "Loading...";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchLocationAndWeatherData();
  }

  Future<void> _fetchLocationAndWeatherData() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      await Permission.location.request();
    }

    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _fetchWeatherData(position.latitude, position.longitude);
      await _fetchEarthquakeData(position.latitude, position.longitude);
    } else {
      setState(() {
        _errorMessage = "Permission denied. Cannot fetch weather data.";
      });
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'e4a0d1b5cb7af67e20d0052c1cf534ec'; // Ganti dengan API key Anda
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _weatherInfo = "Temperature: ${data['main']['temp']}°C\n"
            "Weather: ${data['weather'][0]['description']}\n"
            "Location: ${data['name']}, ${data['sys']['country']}";
      });
    } else {
      setState(() {
        _weatherInfo = "Failed to load weather data";
      });
    }
  }

  Future<void> _fetchEarthquakeData(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['features'].isNotEmpty) {
        StringBuffer earthquakeInfoBuffer = StringBuffer();

        for (var earthquake in data['features']) {
          double quakeLat = earthquake['geometry']['coordinates'][1];
          double quakeLon = earthquake['geometry']['coordinates'][0];
          double distance = Geolocator.distanceBetween(lat, lon, quakeLat, quakeLon) / 1000; // distance in km

          if (distance <= 100) {
            earthquakeInfoBuffer.writeln("Magnitude: ${earthquake['properties']['mag']}\n"
                "Location: ${earthquake['properties']['place']}\n"
                "Distance: ${distance.toStringAsFixed(2)} km\n");
          }
        }

        if (earthquakeInfoBuffer.isNotEmpty) {
          setState(() {
            _earthquakeInfo = earthquakeInfoBuffer.toString();
          });
        } else {
          setState(() {
            _earthquakeInfo = "No recent earthquakes nearby.";
          });
        }
      } else {
        setState(() {
          _earthquakeInfo = "No recent earthquakes.";
        });
      }
    } else {
      setState(() {
        _earthquakeInfo = "Failed to load earthquake data";
      });
    }
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
              'CUACA & GEMPA',
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
                      if (_errorMessage.isNotEmpty) ...[
                        Text(_errorMessage, style: TextStyle(color: Colors.red)),
                      ],
                      // Card for Weather Information
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            title: Text(
                              'Informasi Cuaca',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _weatherInfo,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      // Card for Earthquake Prediction
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            title: Text(
                              'Prediksi Gempa',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _earthquakeInfo,
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
            icon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DashboardPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => UserPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          }
        },
      ),
    );
  }
}
