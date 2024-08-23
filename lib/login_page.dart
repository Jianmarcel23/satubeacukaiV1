import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'forgot_password_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink()), // Menghilangkan tulisan pada AppBar
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/bea_cukai.png',
                    width: 90,
                    height: 90,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 3,
                  height: 40,
                  color: Colors.black,
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/kemenkeu.png',
                    width: 90,
                    height: 90,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(usernameController, 'NIP'),
            SizedBox(height: screenSize.height * 0.02),
            _buildTextField(passwordController, 'Password', obscureText: !_isPasswordVisible),
            SizedBox(height: screenSize.height * 0.02),
            _buildForgotPasswordLink(context),
            SizedBox(height: screenSize.height * 0.02),
            _buildLoginButton(context, usernameController, passwordController),
          ],
        ),
      ),
    );
  }

  /// Membangun TextFormField untuk input NIP atau Password
  /// [controller] mengontrol teks yang dimasukkan di TextField
  /// [label] adalah label yang ditampilkan di TextField
  /// [obscureText] menentukan apakah teks harus disembunyikan (misalnya, untuk input password)
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: label == 'Password' ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ) : null,
      ),
    );
  }

  /// Membuat link untuk mengarahkan pengguna ke halaman 'Lupa Password'
  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
          );
        },
        child: const Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Membuat tombol untuk melakukan login
  /// [usernameController] dan [passwordController] digunakan untuk mengambil data input dari pengguna
  Widget _buildLoginButton(BuildContext context, TextEditingController usernameController, TextEditingController passwordController) {
    return ElevatedButton(
      onPressed: () async {
        final nip = usernameController.text;
        final password = passwordController.text;

        final employeeData = await _getEmployeeData(nip);

        if (employeeData != null && employeeData['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(currentUserId: nip)),
          );
        } else {
          _showLoginFailedDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  /// Mengambil data pegawai dari Firestore berdasarkan NIP
  /// [nip] adalah NIP pegawai yang akan dicari
  Future<Map<String, dynamic>?> _getEmployeeData(String nip) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('employees').doc(nip).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  /// Menampilkan dialog saat login gagal
  void _showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: const Text('NIP atau password salah.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
