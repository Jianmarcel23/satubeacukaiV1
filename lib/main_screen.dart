import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel, EventList;
import 'package:intl/intl.dart';
import 'dart:async';

class EventModel implements EventInterface {
  final String title;
  final DateTime date;

  EventModel({required this.title, required this.date});

  @override
  DateTime getDate() {
    return date;
  }

  @override
  Widget? getIcon() {
    return null;
  }

  @override
  String getTitle() {
    return title;
  }

  @override
  String? getDescription() {
    return null;
  }

  @override
  Widget? getDot() {
    return null;
  }

  @override
  int? getId() {
    return null;
  }

  @override
  String? getLocation() {
    return null;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _currentTime;
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = _formatTime(DateTime.now());
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  final List<EventModel> events = [
    EventModel(title: 'Meeting', date: DateTime(2022, 2, 28)),
    EventModel(title: 'Birthday Party', date: DateTime(2022, 3, 15)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Color.fromARGB(255, 248, 248, 248)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/foto.png'), // Ganti dengan path foto karyawan
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Current Time: $_currentTime',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCheckedIn = !_isCheckedIn;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    child: Text(
                      _isCheckedIn ? 'Check Out' : 'Check In',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: CalendarCarousel<EventModel>(
                      onDayPressed: (DateTime date, List<EventModel> events) {
                        print(date);
                        print(events);
                      },
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      thisMonthDayBorderColor: Colors.grey,
                      height: 420.0,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap(),
                      markedDateShowIcon: true,
                      markedDateIconMaxShown: 2,
                      headerTextStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
                      weekdayTextStyle: const TextStyle(fontSize: 16.0, color: Colors.white),
                      prevDaysTextStyle: const TextStyle(fontSize: 14.0, color: Colors.white),
                      nextDaysTextStyle: const TextStyle(fontSize: 14.0, color: Colors.white),
                      markedDateMoreShowTotal: true,
                      markedDateIconBuilder: (event) {
                        return const Icon(Icons.event);
                      },
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

  EventList<EventModel> _markedDateMap() {
    EventList<EventModel> markedDateMap = EventList<EventModel>(events: {});

    for (var event in events) {
      DateTime date = event.date;
      markedDateMap.add(date, event);
    }

    return markedDateMap;
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
  ));
}
