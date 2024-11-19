import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/home/home_screen.dart';
import 'package:gbsw_capstone_appsters/screens/profile/profile_screen.dart';
import 'package:gbsw_capstone_appsters/screens/rank/rank_screen.dart';
import 'package:gbsw_capstone_appsters/style/colors.dart';

class MainNaviator extends StatefulWidget {
  const MainNaviator({super.key});

  @override
  State<MainNaviator> createState() => _MainNaviatorState();
}

class _MainNaviatorState extends State<MainNaviator> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RankScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: '랭크',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
