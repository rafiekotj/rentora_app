import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/home/home_screen.dart';
import 'package:rentora_app/views/notification/notification_screen.dart';
import 'package:rentora_app/views/transaction_history/transaction_history_screen.dart';
import 'package:rentora_app/views/user_account/user_account_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  // Tampilkan halaman sesuai tab yang dipilih
  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return HomeScreen();
    } else if (_selectedIndex == 1) {
      return NotificationScreen();
    } else if (_selectedIndex == 2) {
      return TransactionHistoryScreen();
    } else {
      return UserAccountScreen();
    }
  }

  // Handler saat tab dipilih
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Symbols.home, fill: 0, weight: 600),
              activeIcon: Icon(Symbols.home, fill: 1, weight: 600),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.notifications, fill: 0, weight: 600),
              activeIcon: Icon(Symbols.notifications, fill: 1, weight: 600),
              label: "Notifikasi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.article, fill: 0, weight: 600),
              activeIcon: Icon(Symbols.article, fill: 1, weight: 600),
              label: "Transaksi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.person, fill: 0, weight: 600),
              activeIcon: Icon(Symbols.person, fill: 1, weight: 600),
              label: "Akun",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: AppColor.textHint,
          backgroundColor: AppColor.surface,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
