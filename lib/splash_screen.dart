import 'package:flutter/material.dart';
import 'dart:async'; // Untuk menggunakan delay
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<Offset> _logoAnimation;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi untuk logo yang bergerak dari atas
    _logoController = AnimationController(
      duration: Duration(seconds: 1), // Durasi animasi logo
      vsync: this,
    );

    _logoAnimation = Tween<Offset>(
      begin: Offset(0, -1), // Mulai dari atas layar
      end: Offset(0, 0),  // Berhenti tepat di atas teks
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut, // Gerakan smooth
    ));

    // Animasi untuk teks yang menunggu logo dan kemudian menabrak
    _textController = AnimationController(
      duration: Duration(milliseconds: 700), // Durasi animasi teks
      vsync: this,
    );

    _textAnimation = Tween<Offset>(
      begin: Offset(0, 0.2), // Mulai sedikit di bawah logo
      end: Offset(0, 0),    // Berhenti di posisi tepat di bawah logo
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticInOut, // Efek elastis
    ));

    // Mulai animasi logo
    _logoController.forward();

    // Setelah logo selesai, jalankan animasi teks
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 100), () {
          _textController.forward();
        });

        // Delay sebelum berpindah ke halaman login
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginPage(), // Navigasi ke halaman login
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58403B), // Warna latar belakang
      body: Center(
        child: Stack(
          alignment: Alignment.center, // Menyusun elemen di tengah
          children: [
            // Logo dengan animasi posisi
            SlideTransition(
              position: _logoAnimation,
              child: Image.asset(
                'assets/images/logo_rumah.png',
                height: 333, // Ukuran gambar
                width: 500,
              ),
            ),
            // Teks "SMART HOME" dengan animasi muncul dari bawah
            Positioned(
              top: 250, // Sesuaikan posisi teks untuk berada tepat di bawah logo
              child: SlideTransition(
                position: _textAnimation,
                child: Text(
                  'S M A R T H O U S E',
                  style: TextStyle(
                    color: Colors.white, // Warna teks putih
                    fontFamily: 'Unica One', // Menggunakan font Unica One
                    fontSize: 20, // Ukuran font
                    fontWeight: FontWeight.bold, // Teks tebal
                    letterSpacing: 2.0, // Jarak antar huruf
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
