import 'package:flutter/material.dart';
import 'login_page.dart'; // Mengimport file login_page.dart

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward(); // Jalankan animasi saat initState dipanggil
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Menghilangkan tulisan pada AppBar
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
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
                          width: 90, // Ubah ukuran logo menjadi lebih kecil
                          height: 90, // Ubah ukuran logo menjadi lebih kecil
                        ),
                      ),
                      const SizedBox(width: 20), // Atur jarak antara logo menggunakan SizedBox
                      Container(
                        width: 3, // Lebar pembatas
                        height: 40, // Tinggi pembatas sesuai dengan tinggi logo
                        color: Colors.black, // Warna pembatas
                      ),
                      const SizedBox(width: 20), // Atur jarak antara logo menggunakan SizedBox
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/kemenkeu.png',
                          width: 90, // Ubah ukuran logo menjadi lebih kecil
                          height: 90, // Ubah ukuran logo menjadi lebih kecil
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: () {
                      // Navigasi ke halaman login saat tombol floating ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    backgroundColor: Colors.blue, // Warna latar belakang tombol floating
                    child: const Icon(Icons.arrow_forward), // Icon untuk tombol floating
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
