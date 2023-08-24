import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';

import 'tasks.dart';
import '../components/text_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 1;
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.of(context, rootNavigator: true).pushNamed(_routeNames[index]);
    }
  }

  final List<String> _routeNames = [
    '/friend',
    '/home',
    '/profile',
  ];

  final fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
          child: SvgPicture.asset('public/images/HAPIT_logo.svg'),
        ),
        leadingWidth: 100,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 21, bottom: 7),
          child: Text(
            '홈',
            style: AppTextStyle.bodyMedium,
          ),
        ),
        backgroundColor: AppColors.background1,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 10,
      ),
      body: const Tasks(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/friend_off.svg'),
              activeIcon: SvgPicture.asset('public/images/friend_on.svg'),
              label: ''),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/home_off.svg'),
              activeIcon: SvgPicture.asset('public/images/home_on.svg'),
              label: ''),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/profile_off.svg'),
              activeIcon: SvgPicture.asset('public/images/profile_on.svg'),
              label: ''),
        ],
        fixedColor: AppColors.buttonStroke,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
