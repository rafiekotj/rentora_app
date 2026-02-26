import 'package:flutter/material.dart';
// import 'package:rentora_app/views/auth/login.dart';
import 'package:rentora_app/views/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: HomePage(),
    );
  }
}
