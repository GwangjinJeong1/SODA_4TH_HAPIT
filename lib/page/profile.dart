import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  late String nickname = "";
  late String email = "";
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '프로필 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Image.network(widget.user!.data()!['profile']),
            Text('닉네임: $nickname'),
            Text('이메일: $email'),
          ],
        ),
      ),
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
