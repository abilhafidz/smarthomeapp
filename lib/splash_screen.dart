import 'package:flutter/material.dart';
import 'main.dart'; // Import AuthWrapper

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay 5 seconds before navigating to the AuthWrapper (untuk pengecekan autentikasi)
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthWrapper(), // Pastikan autentikasi diperiksa setelah SplashScreen
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58403B), // Warna latar belakang
      body: Center(
        child: Stack(
          alignment: Alignment.center, // Menyusun elemen di tengah
          children: [
            // Gambar logo
            Image.asset(
              'assets/images/logo_rumah.png',
              height: 333, // Ukuran gambar
              width: 500,
            ),
            // Teks "SMART HOME"
            Positioned(
              top: 220, // Atur nilai ini untuk memindahkan teks lebih dekat ke gambar
              child: Text(
                'S M A R T H O M E',
                style: TextStyle(
                  color: Colors.white, // Warna teks putih
                  fontFamily: 'Unica One', // Menggunakan font Unica One
                  fontSize: 20, // Ukuran font
                  fontWeight: FontWeight.bold, // Teks tebal
                  letterSpacing: 2.0, // Jarak antar huruf
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
