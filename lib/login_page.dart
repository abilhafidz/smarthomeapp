import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_page.dart'; // Pastikan ini mengarah ke file Register Anda
import 'switch_state.dart'; // Pastikan ini mengarah ke file SwitchState Anda
import 'mqtt_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; // Variabel untuk menyimpan status visibility password
  bool _isHovered = false; // Variabel untuk menyimpan status hover tombol
  bool _isPressed = false; // Variabel untuk menyimpan status ketika tombol ditekan
  final TextEditingController _emailController = TextEditingController(); // Mengubah username menjadi email
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Inisialisasi Firebase Auth

  // Cek apakah input email dan password terisi
  bool get _isInputFilled => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _login() async {
    try {
      // Masukkan email dan password pengguna
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text, // Menggunakan email
        password: _passwordController.text,
      );

      // Mengambil instance dari SwitchState
      final switchState = Provider.of<SwitchState>(context, listen: false);

      // Menambahkan logika untuk menghubungkan ke MQTT setelah login berhasil
      await switchState.mqttService.connect();

      // Tampilkan snackbar atau dialog sebagai indikasi login berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil!')),
      );

    } on FirebaseAuthException catch (e) {
      // Menangani kesalahan otentikasi
      String message = e.message ?? 'Login gagal, silakan coba lagi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Kesalahan umum
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58403B), // Warna latar belakang sesuai dengan gambar
      body: Stack(
        children: [
          // Hiasan di pojok atas kanan
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 187,
              height: 47,
              decoration: BoxDecoration(
                color: Color(0xFFE5C6B6), // Warna hiasan
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50), // Radius untuk pojok bawah kiri
                ),
              ),
            ),
          ),
          // Hiasan di pojok bawah kiri
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 187,
              height: 47,
              decoration: BoxDecoration(
                color: Color(0xFFE5C6B6), // Warna hiasan
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50), // Radius untuk pojok atas kanan
                ),
              ),
            ),
          ),
          // Konten utama dengan StreamBuilder
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // Padding di sekitar form
              child: StreamBuilder<User?>( // Stream untuk memantau status autentikasi
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  // Jika pengguna sudah login, tampilkan snackbar
                  if (snapshot.hasData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Anda sudah login!')),
                    );
                    // Tidak mengarahkan ke DashboardPage
                  }

                  // Jika belum login, tampilkan form login
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_rumah.png',
                        height: 200, // Memperbesar ukuran logo
                      ),
                      SizedBox(height: 20), // Jarak antara logo dan teks
                      Text(
                        'SMART HOME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28, // Memperbesar ukuran teks agar proporsional
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40), // Jarak antara teks dan form
                      Card(
                        color: Color(0xFFFAE7D7), // Warna latar belakang card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0), // Sudut card
                        ),
                        elevation: 4, // Bayangan card
                        child: Padding(
                          padding: const EdgeInsets.all(24.0), // Padding di dalam card
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Input Email
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54), // Garis stroke
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: _emailController, // Mengubah menjadi email controller
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'email',
                                    hintStyle: TextStyle(color: Colors.black54), // Warna hint text
                                    border: InputBorder.none, // Tanpa garis tepi
                                    contentPadding: EdgeInsets.all(12), // Padding di dalam input
                                  ),
                                  keyboardType: TextInputType.emailAddress, // Mengatur input menjadi email
                                  onChanged: (value) {
                                    setState(() {}); // Update tampilan saat isi berubah
                                  },
                                ),
                              ),
                              SizedBox(height: 20), // Jarak antara input email dan password
                              // Input Password
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54), // Garis stroke
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'password',
                                    hintStyle: TextStyle(color: Colors.black54), // Warna hint text
                                    border: InputBorder.none, // Tanpa garis tepi
                                    contentPadding: EdgeInsets.all(12), // Padding di dalam input
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText; // Toggle visibility
                                        });
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {}); // Update tampilan saat isi berubah
                                  },
                                ),
                              ),
                              SizedBox(height: 30), // Jarak antara input password dan tombol sign in
                              // Tombol Sign In
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _isPressed = true; // Tombol ditekan
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _isPressed = false; // Tombol dilepas
                                  });
                                  if (_isInputFilled) {
                                    _login(); // Panggil metode login jika input terisi
                                  }
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isPressed = false; // Reset status jika cancel
                                  });
                                },
                                child: MouseRegion(
                                  onEnter: (_) {
                                    if (_isInputFilled) {
                                      setState(() => _isHovered = true);
                                    }
                                  },
                                  onExit: (_) {
                                    setState(() {
                                      _isHovered = false;
                                      _isPressed = false; // Reset status saat keluar
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54), // Garis stroke
                                      borderRadius: BorderRadius.circular(8),
                                      color: _isPressed
                                          ? Color(0xFF4E3B31) // Warna saat ditekan
                                          : _isHovered && _isInputFilled
                                          ? Color(0xFF4E3B31) // Warna saat hover
                                          : Color(0xFFFAE7D7), // Warna latar belakang
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                                      child: Text(
                                        'SIGN IN',
                                        style: TextStyle(
                                          color: _isPressed || (_isHovered && _isInputFilled)
                                              ? Colors.white
                                              : Colors.black, // Warna teks tombol
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20), // Jarak antara tombol sign in dan teks pendaftaran
                              // Teks untuk pendaftaran
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterPage(), // Navigasi ke halaman Register
                                    ),
                                  );
                                },
                                child: Text(
                                  'belum daftar? daftar',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline, // Garis bawah pada teks
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
