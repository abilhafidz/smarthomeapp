import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';
import 'weather.dart';
import 'about_us.dart';
import 'update_akun.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 2;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }


  void _getCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        currentUser = null;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });


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

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WeatherPage(),
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


  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print("Error signing out: $e");
              }
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
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
          'User Profile',
          style: TextStyle(
            color: Color(0xFF66544D),
            fontFamily: 'Unica One',
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

              _buildUserCard(),

            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildUserCard() {
    return Card(
      color: const Color(0xFFFAEBD7),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_pin,
              size: 120,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            _buildBeautifiedFrame(),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifiedFrame() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOptionRow(Icons.email, 'Email: ${currentUser?.email ?? 'Not available'}'),
          const Divider(color: Color(0xFF66544D)),
          _buildOptionButton(Icons.info, 'Tentang kami', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUsPage()),
            );
          }),
          _buildOptionButton(Icons.edit, 'Edit akun', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateAkunPage()),
            );
          }),
          const Divider(color: Color(0xFF66544D)),
          _buildOptionButton(Icons.logout, 'Log Out', _handleLogout),
        ],
      ),
    );
  }

  Widget _buildOptionRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontFamily: 'Unica One',
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(IconData icon, String text, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black87),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontFamily: 'Unica One',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(alignment: Alignment.centerLeft),
    );
  }


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
      selectedLabelStyle: TextStyle(
        fontFamily: 'Unica One',

      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Unica One',

      ),
      onTap: _onItemTapped,
    );
  }
}
