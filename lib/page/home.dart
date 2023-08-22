import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_to_do/components/colors.dart';
import '../crud/add_habit.dart';
import 'tasks.dart';
import '../components/textStyle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    const Center(child: Text('Friend')),
    const Tasks(),
    const Center(child: Text('Profile')),
  ];

  final fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SvgPicture.asset('public/images/HAPIT_logo.svg',
              width: 78, height: 18.5),
        ),
        leadingWidth: 80,
        centerTitle: true,
        title: Text(
          '홈',
          style: AppTextStyle.bodyMedium,
        ),
        elevation: 2,
        backgroundColor: AppColors.background1,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AddListButton extends StatelessWidget {
  const AddListButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 158,
          height: 70,
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 9, top: 15, right: 24, bottom: 20),
                  backgroundColor: AppColors.friendPlus,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 7),
              child: Row(
                children: [
                  SvgPicture.asset('public/images/friend_off.svg',
                      width: 41, height: 36.5),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('친구와 함께', style: AppTextStyle.sub1),
                      Text('습관 만들기', style: AppTextStyle.sub3),
                    ],
                  ),
                ],
              )),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: 158,
          height: 70,
          child: Expanded(
            child: ElevatedButton(
                onPressed: () {
                  Future.delayed(
                    const Duration(seconds: 0),
                    () => showModalBottomSheet(
                      context: context,
                      builder: (context) => const AddHabit(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                        left: 9, top: 15, right: 24, bottom: 20),
                    backgroundColor: AppColors.alonePlus,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 7),
                child: Row(
                  children: [
                    Icon(Icons.add),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나만의', style: AppTextStyle.sub1),
                        Text('습관 만들기----------', style: AppTextStyle.sub3),
                      ],
                    ),
                  ],
                )),
          ),
        )
      ],
    );
  }
}
