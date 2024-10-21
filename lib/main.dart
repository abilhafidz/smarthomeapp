import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart'; // Halaman login
import 'dashboard.dart'; // Halaman dashboard
import 'switch_state.dart'; // Kelas untuk state switch
import 'mqtt_service.dart'; // Kelas MqttService
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth untuk autentikasi
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'firebase_options.dart'; // File firebase_options.dart yang dihasilkan
import 'splash_screen.dart'; // Import SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Menjamin inisialisasi yang tepat

  // Inisialisasi Firebase dengan konfigurasi platform
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Menggunakan opsi Firebase sesuai platform
    );
  } catch (e) {
    print("Failed to initialize Firebase: $e"); // Pengecekan error jika Firebase gagal diinisialisasi
  }

  // Menjalankan aplikasi dengan ChangeNotifierProvider untuk SwitchState dan MqttService
  runApp(
    ChangeNotifierProvider(
      create: (context) => SwitchState(MqttService()),
      child: SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Tampilkan SplashScreen terlebih dahulu
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      routes: {
        '/login': (context) => LoginPage(),

      },
    );
  }
}

