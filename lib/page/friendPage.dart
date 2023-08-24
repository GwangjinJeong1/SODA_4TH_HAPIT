import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentUserNickname; // To store the current user's nickname

  @override
  void initState() {
    super.initState();
    _getCurrentUserNickname();
  }

  Future<void> _getCurrentUserNickname() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserNickname = user.displayName;
      });
    }
  }

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
      body: _buildFriendPageBody(),
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

  Widget _buildFriendPageBody() {
    if (_currentUserNickname != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> rooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final roomData = rooms[index].data() as Map<String, dynamic>;
              final participants = roomData['participants'] ?? [];

              if (participants.contains(_currentUserNickname)) {
                final String purpose = roomData['purpose'] ?? 'No Purpose';

                return ListTile(
                  title: Text('Room Purpose: $purpose'),
                );
              } else {
                return Container(); // Return an empty container if the user's nickname is not in participants
              }
            },
          );
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
