import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'weather.dart'; // Pastikan ini adalah file cuaca yang kamu buat
import 'switch_state.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 2; // Set to 2 because this is the UserPage
  User? currentUser; // Firebase User object
  String? username; // To store the username from Firestore

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get current logged-in user's email and username (if available)
  void _getCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Fetch the username from Firestore using the current user's UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc.get('username'); // Get the username from Firestore
        });
      } else {
        setState(() {
          username = 'User not found'; // Handle the case where the user is not found
        });
      }
    } else {
      setState(() {
        username = 'Not logged in'; // Provide a message if user is not logged in
      });
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigate to the corresponding page
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DashboardPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = 0.0;
              var end = 1.0;
              var curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      } else if (index == 1) {
        // Navigate to WeatherPage
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WeatherPage(), // Halaman cuaca
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = 0.0;
              var end = 1.0;
              var curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  // Function to handle logout
  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase logout
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: const Color(0xFFFAEBD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'USER PROFILE',
          style: TextStyle(
            color: Color(0xFF66544D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF5B4741),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // User information card
              _buildUserCard(),
              const SizedBox(height: 20),
              // Log out button
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Function to build user information card
  Widget _buildUserCard() {
    return Card(
      color: const Color(0xFFFAEBD7),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.person_pin,
              size: 120,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            _buildBeautifiedText('Email: ${currentUser?.email ?? 'Not available'}'),
            const SizedBox(height: 10),
            _buildBeautifiedText('Username: ${username ?? 'Not available'}'),
          ],
        ),
      ),
    );
  }

  // Function to create beautifully framed text widgets for email and username
  Widget _buildBeautifiedText(String text) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3DAC9), Color(0xFFF5DEB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Color(0xFF66544D), width: 2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Function to build the logout button
  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFAEBD7),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: const Text(
        'Log Out',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Function to build the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      onTap: _onItemTapped,
    );
  }
}
