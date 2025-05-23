import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAEBD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ABOUT US',
          style: TextStyle(
            color: Color(0xFF66544D),
            fontSize: 24,
            fontFamily: 'Unica One',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF5B4741),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/logo.png'), // Ganti dengan logo aplikasi jika ada
              ),
              const SizedBox(height: 20),
              const Text(
                'Smart House App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Unica One',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kami adalah tim yang berfokus pada pengembangan solusi rumah pintar(Smarthouse) '
                    'yang terintegrasi dengan teknologi IoT dan mobile device. '
                    'Aplikasi ini bertujuan untuk memberikan kontrol mudah dan efisien '
                    'terhadap perangkat-perangkat pintar di rumah Anda,'
                    'dilengkapi dengan kontrol pintu , status lampu, dan pendeteksi gas atau asap '
                    'juga dilengkapi dengan informasi cuaca, indeks sinar UV, dan kualitas udara. ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Nama Anggota Tim:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '- Muhammad Raynard Aurelio PM (E32231405)\n'
                    '- Muhammad Abil Hafidz (E32231761)\n'
                    '- Fahlim Irmansyah (E32231553)\n'
                    '- Ahmad Novil Akwan (E32231503)\n'
                    '- Mohammad Alir Riydho (E32231556)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Hubungi Kami',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Email: support@smarthomeapp.com\nWebsite: www.smarthomeapp.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
