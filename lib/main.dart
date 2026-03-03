import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: AppColor.secondary,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
