import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:satubeacukai/login_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satubeacukai/attendance_history_page.dart';

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
  late EventList<EventModel> _markedDates;
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
      EventModel(title: 'Meeting', date: DateTime(2024, 8, 28)),
      EventModel(title: 'Birthday Party', date: DateTime(2024, 8, 29)),
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
      child: Text(_isCheckedIn ? 'Check-Out' : 'Check-In'),
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
            Text('Jam Masuk: ${_jamMasuk ?? '-'}'),
            Text('Jam Istirahat: ${_jamIstirahat ?? '-'}'),
            Text('Jam Pulang: ${_jamPulang ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 400, // set a fixed height for the calendar
      child: CalendarCarousel<EventModel>(
        onDayPressed: (DateTime date, List<EventModel> events) {
          print(date);
        },
        daysHaveCircularBorder: true,
        showOnlyCurrentMonthDate: false,
        todayBorderColor: Colors.transparent,
        todayButtonColor: Colors.transparent,
        selectedDayBorderColor: Colors.transparent,
        selectedDayButtonColor: Colors.blue,
        selectedDayTextStyle: const TextStyle(color: Colors.white),
        headerTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        markedDatesMap: _markedDates,
      ),
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
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan QR Code'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScanPage(currentUserId: widget.currentUserId),
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

class QRScanPage extends StatefulWidget {
  final String currentUserId;

  const QRScanPage({super.key, required this.currentUserId});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final nip = scanData.code;
      if (nip != null) {
        Navigator.pop(context); // Close the QR scanner page
        await _handleScannedNIP(nip);
      }
    });
  }

  Future<void> _handleScannedNIP(String nip) async {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final date = DateFormat('yyyy-MM-dd').format(now);

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('employees')
          .where('NIP', isEqualTo: nip)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userId = userQuery.docs.first.id;

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
              'checkIn': formattedTime,
            });
          } else {
            transaction.update(attendanceRef, {
              'checkOut': formattedTime,
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Absensi berhasil disimpan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna dengan NIP tersebut tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance: $e')),
      );
    }
  }
}
