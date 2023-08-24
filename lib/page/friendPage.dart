import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page/friend_part.dart';
import '../components/textStyle.dart';

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
      body: FutureBuilder<List<String>>(
        future: _getRoomsWithUser(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          return FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('rooms').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return const Text('Error');
              }

              final roomsSnapshot = snapshot.data;
              final List<QueryDocumentSnapshot> roomDocs = roomsSnapshot!.docs;

              final List<String> purposes = [];

              for (final roomDoc in roomDocs) {
                final roomData = roomDoc.data() as Map<String, dynamic>;
                final participants = roomData['participants'] as List<dynamic>;

                if (participants.contains(_currentUserNickname)) {
                  final purpose = roomData['purpose'] ?? 'No Purpose';
                  purposes.add(purpose);
                }
              }

              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 180, top: 27, bottom: 23),
                    child: Text("함께 하는 습관목록", style: AppTextStyle.head3),
                  ), // Display once above the list
                  Expanded(
                    child: ListView.builder(
                      itemCount: purposes.length,
                      itemBuilder: (context, index) {
                        final purpose = purposes[index];
                        final roomIndex = roomDocs.indexWhere((roomDoc) =>
                            (roomDoc.data()
                                as Map<String, dynamic>)['purpose'] ==
                            purpose);

                        if (roomIndex >= 0) {
                          final participants = (roomDocs[roomIndex].data()
                                  as Map<String, dynamic>)['participants']
                              as List<dynamic>;

                          // Exclude the current user's nickname from the participants list
                          final filteredParticipants = participants
                              .where((participant) =>
                                  participant != _currentUserNickname)
                              .toList();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoomPage(
                                    roomNumber: int.parse(roomDocs[roomIndex]
                                        .id), // Convert to int
                                    nickname: _currentUserNickname,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  title: Container(
                                    width: 335,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.friendOff,
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 38),
                                          child: Text(purpose,
                                              style: AppTextStyle.body2),
                                        ),
                                        Icon(Icons
                                            .arrow_forward_ios), // Add an arrow icon
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                    'Participants: ${filteredParticipants.join(", ")}'),
                                const Divider(),
                              ],
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text('Room Purpose: $purpose'),
                          );
                        }
                      },
                    ),
                  ),
                ],
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
