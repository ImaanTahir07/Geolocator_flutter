import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Integration',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startSendingGPSData();
  }

  void startSendingGPSData() {
    const duration = Duration(seconds: 30);
    timer = Timer.periodic(duration, (Timer t) {
      _getCurrentLocation();
    });
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    // Send GPS data to Node.js API
    _sendGPSData(position);
  }

  void _sendGPSData(Position position) async {
    final url =
        "http://192.168.0.112:3000/gps?latitude=${position.latitude.toString()}2&longitude=${position.longitude.toString()}";
    final response = await http.post(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      print('GPS data sent successfully');
    } else {
      print('Failed to send GPS data. Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Integration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _currentPosition != null
                ? Text(
                    'Latitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}',
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'Fetching GPS data...',
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
