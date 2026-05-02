import 'package:flutter/material.dart';

import 'home_page.dart';
import 'device_list_page.dart';
import 'pairing_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    DeviceListPage(),
    PairingPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: "Devices",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_find),
            label: "Pairing",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}