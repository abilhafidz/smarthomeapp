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
  String _weatherInfo = "Memuat...";
  String _earthquakeInfo = "Memuat...";
  String _uvIndexInfo = "Memuat...";
  String _airQualityInfo = "Memuat...";
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
      await _fetchUVIndex(position.latitude, position.longitude);
      await _fetchAirQuality(position.latitude, position.longitude); // Fetch air quality data
    } else {
      setState(() {
        _errorMessage = "Izin ditolak. Tidak dapat mengambil data cuaca.";
      });
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'e4a0d1b5cb7af67e20d0052c1cf534ec'; // Ganti dengan API key Anda
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _weatherInfo = "Temperatur: ${data['main']['temp']}°C\n"
            "Cuaca: ${data['weather'][0]['description']}\n"
            "Lokasi: ${data['name']}, ${data['sys']['country']}";
      });
    } else {
      setState(() {
        _weatherInfo = "Gagal memuat data cuaca";
      });
    }
  }


  Future<void> _fetchUVIndex(double lat, double lon) async {
    final apiKey = 'e4a0d1b5cb7af67e20d0052c1cf534ec'; // Ganti dengan API key Anda
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/uvi?lat=$lat&lon=$lon&appid=$apiKey'), // Permintaan untuk indeks UV
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String uvIndex = data['value'].toString();
      String warningMessage;

      if (double.parse(uvIndex) <= 2) {
        warningMessage = "Indeks Sinar UV: $uvIndex (Rendah)";
      } else if (double.parse(uvIndex) <= 5) {
        warningMessage = "Indeks Sinar UV: $uvIndex (Sedang)";
      } else if (double.parse(uvIndex) <= 7) {
        warningMessage = "Indeks Sinar UV: $uvIndex (Tinggi)";
      } else if (double.parse(uvIndex) <= 10) {
        warningMessage = "Indeks Sinar UV: $uvIndex (Sangat Tinggi)";
      } else {
        warningMessage = "Indeks Sinar UV: $uvIndex (Ekstrem)";
      }

      setState(() {
        _uvIndexInfo = warningMessage + "\nPerhatian: Gunakan pelindung matahari!";
      });
    } else {
      setState(() {
        _uvIndexInfo = "Gagal memuat data indeks sinar UV";
      });
    }
  }

  Future<void> _fetchAirQuality(double lat, double lon) async {
    final apiKey = 'e4a0d1b5cb7af67e20d0052c1cf534ec';
    final response = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aqi = data['list'][0]['main']['aqi'];
      String airQualityLevel;
      String healthRecommendation;

      switch (aqi) {
        case 1:
          airQualityLevel = "Baik";
          healthRecommendation = "Kualitas udara sangat baik. Tidak ada risiko kesehatan.";
          break;
        case 2:
          airQualityLevel = "Sedang";
          healthRecommendation = "Kualitas udara dapat diterima. Beberapa polutan mungkin menimbulkan risiko bagi individu yang sensitif.";
          break;
        case 3:
          airQualityLevel = "Tidak Sehat bagi Kelompok Sensitif";
          healthRecommendation = "Kelompok sensitif mungkin mengalami efek kesehatan.";
          break;
        case 4:
          airQualityLevel = "Tidak Sehat";
          healthRecommendation = "Semua orang mungkin mulai mengalami efek kesehatan.";
          break;
        case 5:
          airQualityLevel = "Sangat Tidak Sehat";
          healthRecommendation = "Semua orang mungkin terkena dampak kesehatan yang serius.";
          break;
        default:
          airQualityLevel = "Tidak Diketahui";
          healthRecommendation = "Tidak ada data kualitas udara tersedia.";
      }

      setState(() {
        _airQualityInfo = "Indeks Kualitas Udara : $aqi ($airQualityLevel)\n$healthRecommendation";
      });
    } else {
      setState(() {
        _airQualityInfo = "Gagal memuat data kualitas udara";
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
              'Weather',
              style: TextStyle(
                color: Color(0xFF66544D),
                fontSize: 24,
                fontFamily: 'Unica One',
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
                            leading: Icon(Icons.cloud, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Informasi Cuaca',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: 'Unica One'),
                            ),
                            subtitle: Text(
                              _weatherInfo,
                              style: TextStyle(fontSize: 18,fontFamily: 'Unica One'),
                            ),
                          ),
                        ),
                      ),

                      // Card for UV Index
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.brightness_7, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Indeks Sinar UV',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: 'Unica One'),
                            ),
                            subtitle: Text(
                              _uvIndexInfo,
                              style: TextStyle(fontSize: 18,fontFamily: 'Unica One'),
                            ),
                          ),
                        ),
                      ),
                      // Card for Air Quality
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(
                            leading: Icon(Icons.air, size: 40, color: Color(0xFF5B4741)),
                            title: Text(
                              'Kualitas Udara',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: 'Unica One'),
                            ),
                            subtitle: Text(
                              _airQualityInfo,
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
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Unica One', // Font yang ingin digunakan untuk label terpilih

        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Unica One', // Font yang ingin digunakan untuk label tidak terpilih

        ),
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
