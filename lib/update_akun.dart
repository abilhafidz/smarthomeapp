import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateAkunPage extends StatefulWidget {
  @override
  _UpdateAkunPageState createState() => _UpdateAkunPageState();
}

class _UpdateAkunPageState extends State<UpdateAkunPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  void _updatePassword(BuildContext context) async {
    User? user = _auth.currentUser;
    String email = user!.email!;
    String oldPassword = _oldPasswordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );

      await userCredential.user!.updatePassword(_newPasswordController.text);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update password berhasil')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password Tidak Valid, Update Gagal')),
        );
      }
    }
  }

  void _showUpdatePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                fillColor: Colors.white,
                filled: true,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                fillColor: Colors.white,
                filled: true,
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _updatePassword(context);
            },
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              User? user = _auth.currentUser;
              await user?.delete();

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hapus Akun berhasil')),
                );
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
          'Update Akun',
          style: TextStyle(
            color: Color(0xFF66544D),
            fontFamily: 'Unica One',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF66544D)),
          onPressed: () => Navigator.of(context).pop(),
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
          _buildOptionButton(Icons.lock, 'Update Password', _showUpdatePasswordDialog),
          const Divider(color: Color(0xFF66544D)),
          _buildOptionButton(Icons.delete, 'Hapus Akun', () => _deleteAccount(context)),
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
}
