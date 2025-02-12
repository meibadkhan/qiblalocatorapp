import 'package:flutter/material.dart';
import 'package:islamic_hijri_calendar/islamic_hijri_calendar.dart';
import 'package:qiblalocatorapp/screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff0c7b93),
        primaryColorLight: const Color(0xff00a8cc),
        primaryColorDark: const Color(0xff27496d),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: const Color(0xffecce6d)),
      ),
      home: QiblaScreen(),
    );
  }
}

