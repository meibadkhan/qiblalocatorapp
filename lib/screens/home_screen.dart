import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamic_hijri_calendar/islamic_hijri_calendar.dart';

import '../widget/compass_widget.dart';
import '../widget/helper_widget.dart';

class QiblaScreen extends StatefulWidget {
  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  final _locationStreamController =
  StreamController<LocationStatus>.broadcast();
  LocationStatus? _currentStatus;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();

    // Fade-in Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();

    _currentStatus = locationStatus; // Store the status

    // Ensure the stream gets updated with new data
    _locationStreamController.sink.add(locationStatus);

    if (!locationStatus.enabled) {
      _showLocationDialog();
    } else if (locationStatus.status == LocationPermission.denied ||
        locationStatus.status == LocationPermission.deniedForever) {
      await FlutterQiblah.requestPermissions();
      final newStatus = await FlutterQiblah.checkLocationStatus();
      _currentStatus = newStatus;
      _locationStreamController.sink.add(newStatus); // Update stream
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enable Location"),
        content:
        const Text("Location services are required to find the Qibla direction."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              _checkLocationStatus();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Qibla Locator"),
      actions: [
        IconButton(onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: IslamicHijriCalendar(
                isHijriView: true,

                adjustmentValue: 0,
                isGoogleFont: true,

                fontFamilyName: "Lato",
                getSelectedHijriDate: (selectedDate) {

                  print("Selected Hijri Date: $selectedDate");
                },
                isDisablePreviousNextMonthDates: true,
              ),
            );
          });
        }, icon: Icon(Icons.calendar_month))
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<bool?>(
          future: _deviceSupport,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error.toString()}"));
            }
            if (snapshot.data == false) {
              return const Center(
                child: Text("Your device does not support the Qiblah feature"),
              );
            }

            return StreamBuilder<LocationStatus>(
              initialData: _currentStatus, // Use initial data from _currentStatus
              stream: _locationStreamController.stream,
              builder: (_, snapshot) {
                print("Stream Data Available: ${snapshot.hasData}");
                print("Location Enabled: ${_currentStatus?.enabled}");
                print("Permission Status: ${_currentStatus?.status}");

                if (!snapshot.hasData) {
                  return LoadingIndicator(); // Show loading until data is available
                }

                final locationStatus = snapshot.data;

                if (locationStatus == null || !locationStatus.enabled) {
                  return LocationErrorWidget(
                    error: "Location is disabled. Please enable it from settings.",
                    callback: _checkLocationStatus,
                  );
                }

                if (locationStatus.status == LocationPermission.denied ||
                    locationStatus.status == LocationPermission.deniedForever) {
                  return LocationErrorWidget(
                    error: "Location permission is denied. Please allow access.",
                    callback: _checkLocationStatus,
                  );
                }

                return QiblahCompassWidget();
              },
            );
          },
        ),
      ),
    );
  }
}
