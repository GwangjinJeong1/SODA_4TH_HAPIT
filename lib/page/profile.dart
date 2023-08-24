import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../components/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  late String nickname = '';
  late String email = '';

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
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          nickname = userDoc['nickname'];
          email = userDoc['email'];
        });
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
          child: SvgPicture.asset('public/images/HAPIT_logo.svg'),
        ),
        leadingWidth: 100,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 21, bottom: 7),
          child: Text(
            '프로필',
            style: TextStyle(
              color: Color.fromRGBO(14, 15, 14, 1),
              fontFamily: 'SpoqaHanSansNeo-Medium',
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        backgroundColor: AppColors.background1,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 10,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SvgPicture.asset('public/images/profile.svg'),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Color.fromRGBO(214, 220, 220, 1),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text('닉네임'),
                ),
                Text(nickname),
              ],
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Color.fromRGBO(214, 220, 220, 1),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('이메일'),
                ),
                Text(email),
                SizedBox(
                  width: 100,
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: (const Color.fromRGBO(237, 237, 237, 1)),
                    ),
                    onPressed: () {
                      const AuthPage();
                    },
                    child: const Text(
                      "로그아웃",
                      style: TextStyle(
                        color: Color.fromRGBO(14, 15, 14, 1),
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Color.fromRGBO(214, 220, 220, 1),
            ),
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
    ));
  }
}
