import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import '../components/textStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final int _selectedIndex = 2;
  late String nickname = '';
  late String email = '';
  bool _isGreen = false;
  final fireStore = FirebaseFirestore.instance;
  final TextEditingController nicknameController = TextEditingController();

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

  final user = FirebaseAuth.instance.currentUser;
  Future<void> fetchUserProfile() async {
    try {
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
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

  void updateNickname(String newNickname) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({'nickname': newNickname});

        setState(() {
          nickname = newNickname; // Update the local state with new nickname
        });

        // Optional: Show a success message or perform other actions
      } catch (error) {
        print('Error updating nickname: $error');
        // Handle error if needed
      }
    }
  }

  void toggleImageColor() {
    setState(() {
      _isGreen = !_isGreen;
    });
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Image.asset(_isGreen
                ? 'public/images/character2.png'
                : 'public/images/character1.png'),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () {
                  toggleImageColor();
                },
                child: Text('사진 바꾸기', style: AppTextStyle.body3)),
            const SizedBox(height: 23),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: AppColors.divider,
            ),
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
                const SizedBox(width: 25),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: TextFormField(
                    controller: nicknameController,
                    style: AppTextStyle.sub5,
                    cursorColor: AppColors.buttonStroke,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: nickname,
                      hintStyle: AppTextStyle.sub5,
                    ),
                    onChanged: (newNickname) {
                      setState(() {
                        nickname = newNickname;
                      });
                    },
                  ),
                ),
              ],
            ),
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
                Text(email,
                    style: const TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Regular',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: AppColors.bodyText2)),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: AppColors.divider,
            ),
            const SizedBox(height: 25),
            Container(
              width: 100,
              height: 34,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ]),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                  onPressed: () {
                    updateNickname(nicknameController.text);

                    Navigator.pop(context, nicknameController.text);
                  },
                  child: Center(child: Text('완료', style: AppTextStyle.body3))),
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
    );
  }
}
