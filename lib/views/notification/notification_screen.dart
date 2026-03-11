import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Symbols.chat, weight: 600)),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(),
    );
  }
}
