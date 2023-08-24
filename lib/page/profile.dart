import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import '../components/text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

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
          child: Text('프로필', style: AppTextStyle.body1),
        ),
        backgroundColor: AppColors.background1,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 10,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 24, right: 20, bottom: 10),
            child: TextButton(
              onPressed: () async {
                await Future.delayed(
                    const Duration(seconds: 0),
                    () => showDialog(
                        context: context,
                        builder: (context) => const DeleteAlert()));
              },
              child: const Text("로그아웃",
                  style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo-Regular',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.bodyText1)),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
                child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                  ),
                  image: const DecorationImage(
                      image: AssetImage('public/images/character1.png'))),
            )),
            const SizedBox(height: 54),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: AppColors.divider,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('닉네임',
                      style: TextStyle(
                          fontFamily: 'SpoqaHanSansNeo-Regular',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.bodyText2)),
                ),
                const SizedBox(width: 34),
                Text(nickname, style: AppTextStyle.sub5),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: AppColors.divider,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('이메일',
                      style: TextStyle(
                          fontFamily: 'SpoqaHanSansNeo-Regular',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.bodyText2)),
                ),
                const SizedBox(width: 34),
                Text(email, style: AppTextStyle.sub5),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: AppColors.divider,
            ),
            const SizedBox(height: 25),
            TextButton(
                onPressed: () async {
                  final updateNickname = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfilePage()),
                  );
                  if (updateNickname != null) {
                    setState(() {
                      nickname = updateNickname;
                    });
                  }
                },
                child: Text('프로필 편집', style: AppTextStyle.body3)),
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

class DeleteAlert extends StatefulWidget {
  const DeleteAlert({super.key});

  @override
  State<DeleteAlert> createState() => _DeleteAlertState();
}

class _DeleteAlertState extends State<DeleteAlert> {
  final user = FirebaseAuth.instance;
  void signOut() async {
    await user.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return AlertDialog(
      scrollable: true,
      title: Image.asset('public/images/logout.png', width: 45, height: 50),
      content: Container(
        margin: const EdgeInsets.only(bottom: 0),
        child: Text(
          '정말 로그아웃 하시겠습니까?',
          style: AppTextStyle.sub1,
          textAlign: TextAlign.center,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Container(
          margin: const EdgeInsets.only(top: 0, bottom: 20),
          width: width * 0.27,
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button1,
            ),
            child: Text('취소하기', style: AppTextStyle.body3),
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 0, bottom: 20),
            width: width * 0.27,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button2,
              ),
              child: Text('로그아웃', style: AppTextStyle.body3),
            ))
      ],
    );
  }
}
