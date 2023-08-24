import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentUserId = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });

      final userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserNickname = userDoc.data()?['nickname'] ?? "No Nickname";
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.pushNamed(context, _routeNames[index]);
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
      appBar: AppBar(
        title: Text("$_currentUserNickname 님의 친구 페이지"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<String>>(
        future: _getRoomsWithUser(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          final List<String> roomsWithUser = snapshot.data ?? [];

          return ListView.builder(
            itemCount: roomsWithUser.length,
            itemBuilder: (context, index) {
              final roomNumber = roomsWithUser[index];
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('rooms').doc(roomNumber).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Error');
                  }

                  final roomData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final purpose = roomData['purpose'] ?? 'No Purpose';

                  return ListTile(
                    title: Text('Room Purpose: $purpose'),
                  );
                },
              );
            },
          );
        },
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

  Future<List<String>> _getRoomsWithUser(String userNickname) async {
    final QuerySnapshot roomsSnapshot =
        await _firestore.collection('rooms').get();

    final List<String> roomNumbers = [];

    for (final roomDoc in roomsSnapshot.docs) {
      final roomData = roomDoc.data() as Map<String, dynamic>;
      final participants = roomData['participants'] ?? [];

      if (participants.contains(userNickname)) {
        roomNumbers.add(roomDoc.id);
      }
    }

    return roomNumbers;
  }
}
