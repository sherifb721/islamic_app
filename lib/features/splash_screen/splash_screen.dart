import 'package:flutter/material.dart';
import 'package:islamic_app/core/theme/color.dart';
import 'package:islamic_app/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5) , () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen();
      },));
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:
        Stack(
          children: [
            //باك جراوند
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  image:DecorationImage(
                      image: AssetImage(
                          "assets/images/background.png") , fit: BoxFit.cover
                  )
              ),
            ),
          ],
        ),
    );
  }
}