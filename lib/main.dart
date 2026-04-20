import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/firebase_options.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/views/splash/splash_screen.dart';
import 'package:rentora_app/services/notification/onesignal_legacy.dart';

// Fungsi utama aplikasi
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi local storage
  await PreferenceHandler().init();
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Aktifkan AppCheck untuk keamanan
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider(),
  );
  // Atur warna status bar
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColor.primary,
      statusBarBrightness: Brightness.light,
    ),
  );
  // Inisialisasi OneSignal hanya di Android native
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      setupOneSignal();
    } catch (_) {}
  }
  // Jalankan aplikasi
  runApp(const MyApp());
}

// Widget utama aplikasi
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
