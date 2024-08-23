import 'package:flutter/material.dart';
import 'login_page.dart'; // Mengimport file login_page.dart

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
        title: const SizedBox.shrink(), // Menghilangkan tulisan pada AppBar
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
                  FloatingActionButton(
                    onPressed: () {
                      // Navigasi ke halaman login saat tombol floating ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.arrow_forward),
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
