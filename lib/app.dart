import 'package:flutter/material.dart';
import 'package:islamic_app/features/splash_screen/splash_screen.dart';

class IslamicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      home:SplashScreen(),
    );
  }
}