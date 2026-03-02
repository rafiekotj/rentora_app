import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator_extension.dart';
import 'package:rentora_app/views/auth/login_screen.dart';
import 'package:rentora_app/views/home/home_screen.dart';
import 'package:rentora_app/services/local/preference_handler.dart';

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
      context.pushAndRemoveAll(HomePage());
    } else {
      context.pushAndRemoveAll(LoginPage());
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
