import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/auth/login_screen.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFB3E5FC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Lottie.asset("assets/animations/ShopIcon.json"),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      FadeInUp(
                        child: Text(
                          "Sewa barang jadi mudah dan cepat",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        child: Text(
                          "Mulai sewa sekarang, temukan berbagai produk favoritmu!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: CustomButton(
                    text: "Masuk Sekarang",
                    onPressed: () {
                      context.pushReplacement(const LoginScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
