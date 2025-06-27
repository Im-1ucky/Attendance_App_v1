import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to MyApp after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(87, 171, 247, 1.0),
      body: Center(
          child: Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromRGBO(87, 171, 247, 1.0), width: 4.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Image.asset('assets/images/splashscreen.gif'),
      )),
    );
  }
}
