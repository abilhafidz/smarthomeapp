import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'dashboard.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  bool _isHovered = false;
  bool _isClicked = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {

      return;
    }
    _formKey.currentState!.save();

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String pin = _pinController.text.trim();


    if (pin != '1234') {
      _showError('PIN is incorrect. Please use the correct PIN.');
      return;
    }

    try {

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSuccessDialog();
    } catch (e) {

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
      barrierDismissible:
      false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil Registrasi'),
          content: Text('Login sekarang'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {

    _emailController.clear();
    _passwordController.clear();
    _pinController.clear();


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

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_rumah.png',
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Smart House',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Unica One',
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
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email.';
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
                                  _isClicked = true;
                                });
                                _register();
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
                                        ? Color(0xFF4E3B31)
                                        : _isHovered
                                        ? Color(0xFF4E3B31)
                                        : Color(0xFFFAE7D7),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 40),
                                    child: Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        fontFamily: "Unica One",
                                        color: _isClicked
                                            ? Colors
                                            .white
                                            : _isHovered
                                            ? Colors.white
                                            : Colors
                                            .black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {

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

  Widget _buildTextField(String hint, TextEditingController controller,
      String? Function(String?)? validator) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.black,fontFamily: "Unica One"),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54,fontFamily: "Unica One"),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
        validator: validator,
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
        style: TextStyle(color: Colors.black,fontFamily: "Unica One"),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.black54,fontFamily: "Unica One"),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
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
