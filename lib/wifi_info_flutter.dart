import 'package:flutter/material.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class WifiInfoPage extends StatefulWidget {
  const WifiInfoPage({super.key});

  @override
  _WifiInfoPageState createState() => _WifiInfoPageState();
}

class _WifiInfoPageState extends State<WifiInfoPage> {
  String _wifiName = 'Unknown';
  String _ipAddress = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getWifiInfo();
  }

  Future<void> _getWifiInfo() async {
    try {
      String? wifiName = await WifiInfo().getWifiName();
      String? ipAddress = await WifiInfo().getWifiIP();

      if (wifiName != null && ipAddress != null) {
        setState(() {
          _wifiName = wifiName;
          _ipAddress = ipAddress;
        });
      } else {
        setState(() {
          _wifiName = 'Unknown';
          _ipAddress = 'Unknown';
        });
        // Tampilkan pesan kesalahan atau lakukan tindakan lain jika tidak dapat memperoleh informasi Wi-Fi
      }
    } catch (e) {
      print('Error getting Wi-Fi info: $e');
      setState(() {
        _wifiName = 'Unknown';
        _ipAddress = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Wi-Fi Name: $_wifiName'),
            SizedBox(height: 20),
            Text('IP Address: $_ipAddress'),
          ],
        ),
      ),
    );
  }
}
