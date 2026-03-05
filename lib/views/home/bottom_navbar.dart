import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/account/account_screen.dart';
import 'package:rentora_app/views/home/home_screen.dart';
import 'package:rentora_app/views/notification/notification_screen.dart';
import 'package:rentora_app/views/transaction/transaction_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    NotificationScreen(),
    TransactionScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Symbols.home, weight: 700),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.notifications, weight: 700),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.article, weight: 700),
            label: "Transaksi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.person, weight: 700),
            label: "Akun",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.textPrimary,
        backgroundColor: AppColor.textOnPrimary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        onTap: _onItemTapped,
      ),
    );
  }
}
