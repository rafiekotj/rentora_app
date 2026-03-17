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

  Future<void> autoLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final bool? data = await PreferenceHandler.getIsLogin();

    if (!mounted) return;

    if (data == true) {
      context.pushAndRemoveAll(const BottomNavbar());
    } else {
      context.pushAndRemoveAll(const BoardingScreen());
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
