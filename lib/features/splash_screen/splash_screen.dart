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
            //الصورة العلوية
            Image.asset("assets/images/Mosque-01.png") ,
            //الصورة الوسطى
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/OBJECTS (1).png",
                  width: 150,
                  ),
                  Image.asset("assets/images/Islami (1).png",
                    width: 150,
                    ),
                ],
              ),
            ),
            //الصور الجانبية
            Positioned(
              right: 5,
              child: Image.asset("assets/images/Glow.png"),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset("assets/images/Shape-04.png",
                width: 101,
                height: 215,
                fit: BoxFit.contain,
              ),

            ),
            Positioned(
              left: 0,
              top: 180,
              child: Image.asset("assets/images/Shape-07.png",
                width: 101,
                height: 215,
                fit: BoxFit.contain,
              ),

            ),
            //النص المكتوب اسفل الشاشة
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Created by: Sherif Hamada",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.gold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}