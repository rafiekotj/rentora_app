import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/firebase_options.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Aktifkan App Check (gunakan provider sesuai kebutuhan, debug untuk development)
  await FirebaseAppCheck.instance.activate(
    providerAndroid:
        AndroidDebugAppCheckProvider(), // Ganti ke AndroidPlayIntegrityAppCheckProvider() untuk production
    providerApple:
        AppleDebugAppCheckProvider(), // Ganti ke AppleDeviceCheckAppCheckProvider() untuk production
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColor.primary,
      statusBarBrightness: Brightness.dark,
    ),
  );

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
        textTheme: const TextTheme().apply(
          bodyColor: AppColor.textPrimary,
          displayColor: AppColor.textPrimary,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: AppColor.secondary,
          cursorColor: AppColor.primary,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
