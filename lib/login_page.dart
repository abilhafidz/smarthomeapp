import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_page.dart';
import 'switch_state.dart';
import 'mqtt_service.dart';
import 'dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _isHovered = false;
  bool _isPressed = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  bool get _isInputFilled => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _login() async {
    try {

      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );


      final switchState = Provider.of<SwitchState>(context, listen: false);


      await switchState.mqttService.connect();


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil! , Selamat datang!!')),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email atau kata sandi yang Anda masukkan salah. Silakan coba lagi')),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, silakan coba lagi.')),
      );
    }
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

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.black,fontFamily: "Unica One"),
                              decoration: InputDecoration(
                                hintText: 'email',
                                hintStyle: TextStyle(color: Colors.black54,fontFamily: 'Unica One'),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(height: 20),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              style: TextStyle(color: Colors.black,fontFamily: "Unica One"),
                              decoration: InputDecoration(
                                hintText: 'password',
                                hintStyle: TextStyle(color: Colors.black54,fontFamily: 'Unica One'),
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
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(height: 30),

                          GestureDetector(
                            onTapDown: (_) {
                              setState(() {
                                _isPressed = true;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                _isPressed = false;
                              });
                              if (_isInputFilled) {
                                _login();
                              }
                            },
                            onTapCancel: () {
                              setState(() {
                                _isPressed = false;
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
                                  _isPressed = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _isPressed
                                      ? Color(0xFF4E3B31)
                                      : _isHovered && _isInputFilled
                                      ? Color(0xFF4E3B31)
                                      : Color(0xFFFAE7D7),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                                  child: Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontFamily:'Unica One',
                                      color: _isPressed || (_isHovered && _isInputFilled)
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'belum daftar? daftar',
                              style: TextStyle(
                                color: Colors.black,
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
        ],
      ),
    );
  }
}
