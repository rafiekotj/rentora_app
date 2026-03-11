import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text(
          "Riwayat Transaksi",
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
