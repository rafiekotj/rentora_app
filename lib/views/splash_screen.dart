import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/views/boarding/boarding_screen.dart';
import 'package:rentora_app/views/home/bottom_navbar.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    await Future.delayed(Duration(seconds: 2));
    bool? data = await PreferenceHandler.getIsLogin();
    if (data == null) {
      print("Belum Login");
    } else {
      print("Sudah Login");
    }
    if (data == true) {
      context.pushAndRemoveAll(BottomNavbar());
    } else {
      context.pushAndRemoveAll(BoardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset("assets/icons/rentora_logo.png", width: 240)],
        ),
      ),
      backgroundColor: AppColor.backgroundLight,
    );
  }
}
