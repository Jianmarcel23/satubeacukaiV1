import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatelessWidget {
  final String userId;

  const AttendanceHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your UI here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
      ),
      body: Center(
        child: Text('Menampilkan riwayat absensi untuk pengguna ID: $userId'),
      ),
    );
  }
}
