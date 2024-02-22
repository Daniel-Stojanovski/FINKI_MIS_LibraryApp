import 'package:flutter/material.dart';
import 'package:library_app/auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'dart:math';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  final String? userEmail;

  const ProfileScreen({Key? key, this.userEmail}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String locationText = 'Fetching location...';
  String magnitudeText = 'Magnetometer not available';
  bool isFetchingMagnitude = false;
  StreamSubscription<MagnetometerEvent>? _magnetometerShow;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _magnetometerShow?.cancel();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        locationText = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        locationText = 'Error fetching location';
      });
    }
  }

  void _startMagnetometer() {
    if (!isFetchingMagnitude) {
      _magnetometerShow = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          double magnitude = _calculateMagnitude(event);
          setState(() {
            magnitudeText = '$magnitude';
          });
        },
        onError: (error) {
          setState(() {
            magnitudeText = 'Magnetometer Error';
          });
        },
        cancelOnError: true,
      );
      setState(() {
        isFetchingMagnitude = true;
      });
    } else {
      _magnetometerShow?.cancel();
      setState(() {
        magnitudeText = 'Magnetometer Stopped';
        isFetchingMagnitude = false;
      });
    }
  }

  double _calculateMagnitude(MagnetometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${widget.userEmail ?? 'Not logged in!'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Location: $locationText',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Magnitude: $magnitudeText',
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Switch(
                  value: isFetchingMagnitude,
                  onChanged: (value) {
                    _startMagnetometer();
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Auth().signOut();
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
