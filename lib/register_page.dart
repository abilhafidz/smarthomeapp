import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import Firestore
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Pastikan untuk mengimpor halaman login
import 'dashboard.dart'; // Pastikan untuk mengimpor halaman dashboard

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  bool _isHovered = false;
  bool _isClicked = false; // Status klik
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // Create an instance of FirebaseAuth and Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final _formKey = GlobalKey<FormState>(); // Form validation key

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      // Jika form tidak valid, berhenti dan kembalikan
      return;
    }
    _formKey.currentState!.save(); // Simpan nilai form

    String email = _emailController.text.trim();
    String username = _usernameController.text.trim(); // Ambil username dari form
    String password = _passwordController.text.trim();
    String pin = _pinController.text.trim();

    // Check if the PIN matches the required PIN
    if (pin != '1234') {
      _showError('PIN is incorrect. Please use the correct PIN.');
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan username ke Firestore dengan user ID
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
      });

      // Tampilkan pop-up setelah registrasi sukses
      _showSuccessDialog();

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase registration errors
      if (e.code == 'email-already-in-use') {
        _showError('Email is already in use. Please use a different email.');
      } else {
        _showError(e.message ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      // Handle general errors
      _showError('An error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Agar dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil Registrasi'),
          content: Text('Login sekarang'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                _navigateToLogin(); // Navigasi ke halaman login
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {
    // Reset form fields
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _pinController.clear();

    // Navigasi ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58403B),
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
                color: Color(0xFFE5C6B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
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
                color: Color(0xFFE5C6B6),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          // Konten utama
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey, // Tambahkan form key untuk validasi
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_rumah.png',
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'SMART HOME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Card(
                      color: Color(0xFFFAE7D7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField('Email', _emailController, (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email.';
                              }
                              return null;
                            }),
                            SizedBox(height: 20),
                            _buildTextField('Username', _usernameController, (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username.';
                              }
                              return null;
                            }),
                            SizedBox(height: 20),
                            _buildPasswordField(),
                            SizedBox(height: 20),
                            _buildTextField('PIN', _pinController, (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the PIN.';
                              }
                              return null;
                            }),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isClicked = true; // Set to true on click
                                });
                                _register(); // Call the registration logic
                              },
                              child: MouseRegion(
                                onEnter: (_) {
                                  if (!_isClicked) {
                                    setState(() => _isHovered = true);
                                  }
                                },
                                onExit: (_) {
                                  setState(() => _isHovered = false);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(8),
                                    color: _isClicked
                                        ? Color(0xFF4E3B31) // Color when clicked
                                        : _isHovered
                                        ? Color(0xFF4E3B31) // Hover color
                                        : Color(0xFFFAE7D7), // Default color
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                                    child: Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        color: _isClicked
                                            ? Colors.white // Text color when clicked
                                            : _isHovered
                                            ? Colors.white
                                            : Colors.black, // Default text color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                // Navigasi kembali ke halaman login
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Sudah punya akun? Kembali',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, String? Function(String?)? validator) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
        validator: validator, // Tambahkan validator
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscureText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password.';
          } else if (value.length < 6) {
            return 'Password must be at least 6 characters.';
          }
          return null;
        },
      ),
    );
  }
}
