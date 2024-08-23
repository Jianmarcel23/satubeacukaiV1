import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:satubeacukai/login_page.dart';

class EventModel implements EventInterface {
  final String title;
  final DateTime date;

  EventModel({required this.title, required this.date});

  @override
  DateTime getDate() => date;

  @override
  Widget? getIcon() => null;

  @override
  String getTitle() => title;

  @override
  String? getDescription() => null;

  @override
  Widget? getDot() => null;

  @override
  int? getId() => null;

  @override
  String? getLocation() => null;
}

class MainScreen extends StatefulWidget {
  final String currentUserId;

  const MainScreen({super.key, required this.currentUserId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late String _currentTime;
  bool _isCheckedIn = false;
  late final EventList<EventModel> _markedDates;
  Future<Map<String, dynamic>?>? _profileFuture;
  late AnimationController _animationController;
  late Animation<double> _animation;

  String? _jamMasuk;
  String? _jamIstirahat;
  String? _jamPulang;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _markedDates = _buildMarkedDateMap();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _profileFuture = _getEmployeeProfile(widget.currentUserId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = _formatTime(DateTime.now());
      _animationController.reset();
      _animationController.forward();
    });
  }

  String _formatTime(DateTime time) => DateFormat('HH:mm:ss').format(time);

  EventList<EventModel> _buildMarkedDateMap() {
    final events = [
      EventModel(title: 'Meeting', date: DateTime(2022, 2, 28)),
      EventModel(title: 'Birthday Party', date: DateTime(2022, 3, 15)),
    ];

    final markedDateMap = EventList<EventModel>(events: {});
    for (var event in events) {
      markedDateMap.add(event.date, event);
    }
    return markedDateMap;
  }

  Future<Map<String, dynamic>?> _getEmployeeProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(userId)
          .get();
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

  void _checkInOrOut() async {
    final now = DateTime.now();
    final formattedTime = _formatTime(now);

    setState(() {
      if (!_isCheckedIn) {
        _jamMasuk = formattedTime;
        _saveAttendance('checkIn', _jamMasuk);
      } else if (_jamMasuk != null && _jamIstirahat == null) {
        _jamIstirahat = formattedTime;
        _saveAttendance('break', _jamIstirahat);
      } else if (_jamIstirahat != null && _jamPulang == null) {
        _jamPulang = formattedTime;
        _saveAttendance('checkOut', _jamPulang);
      }
      _isCheckedIn = !_isCheckedIn;
    });
  }

  Future<void> _saveAttendance(String type, String? time) async {
    if (time == null) return;

    final userId = widget.currentUserId;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final attendanceRef = FirebaseFirestore.instance
          .collection('attendance')
          .doc(userId)
          .collection('records')
          .doc(date);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(attendanceRef);

        if (!docSnapshot.exists) {
          transaction.set(attendanceRef, {
            'date': date,
            'checkIn': type == 'checkIn' ? time : null,
            'break': type == 'break' ? time : null,
            'checkOut': type == 'checkOut' ? time : null,
          });
        } else {
          transaction.update(attendanceRef, {
            if (type == 'checkIn') 'checkIn': time,
            if (type == 'break') 'break': time,
            if (type == 'checkOut') 'checkOut': time,
          });
        }
      });
    } catch (e) {
      print('Error saving attendance: $e');
    }
  }

  Widget _buildProfilePage(Map<String, dynamic> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profile['fotoProfilUrl'] ?? ''),
            radius: 40,
          ),
          title: Text(profile['nama'] ?? ''),
          subtitle: Text(profile['jabatan'] ?? ''),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Nama Lengkap'),
          subtitle: Text(profile['nama'] ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text('NIP'),
          subtitle: Text(profile['NIP'] ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(profile['email'] ?? ''),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Dashboard'),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blue, Colors.indigo],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) =>
                        FutureBuilder<Map<String, dynamic>?>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasData &&
                            snapshot.data != null) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildProfilePage(snapshot.data!),
                          );
                        } else {
                          return const Center(
                              child: Text('Profil tidak ditemukan.'));
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeCard(),
                  const SizedBox(height: 20),
                  _buildCheckInOutButton(),
                  const SizedBox(height: 20),
                  _buildTimeInfoCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Calendar',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildCalendar(),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildTimeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waktu Sekarang: $_currentTime',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInOutButton() {
    return ElevatedButton(
      onPressed: _checkInOrOut,
      child: Text(_isCheckedIn ? 'Check Out' : 'Check In'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isCheckedIn
            ? Colors.red
            : Colors.green, // Adjust the button color based on state
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildTimeInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeInfoRow('Jam Masuk', _jamMasuk),
            _buildTimeInfoRow('Jam Istirahat', _jamIstirahat),
            _buildTimeInfoRow('Jam Pulang', _jamPulang),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value ?? '-',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return CalendarCarousel<EventModel>(
      weekendTextStyle: const TextStyle(
        color: Colors.red,
      ),
      markedDatesMap: _markedDates,
      height: 400.0,
      selectedDateTime: DateTime.now(),
      daysHaveCircularBorder: false,
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Absensi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceHistoryPage(
                      userId: widget.currentUserId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Keluar'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AttendanceHistoryPage extends StatelessWidget {
  final String userId;

  const AttendanceHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .doc(userId)
            .collection('records')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada data absensi.'));
          }
          final records = snapshot.data!.docs;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record =
                  records[index].data() as Map<String, dynamic>? ?? {};
              return ListTile(
                title: Text('Tanggal: ${records[index].id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jam Masuk: ${record['checkIn'] ?? "-"}'),
                    Text('Jam Istirahat: ${record['break'] ?? "-"}'),
                    Text('Jam Pulang: ${record['checkOut'] ?? "-"}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
