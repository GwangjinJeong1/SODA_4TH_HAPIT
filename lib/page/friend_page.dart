import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page/friend_part.dart';
import '../components/text_style.dart';
import '../page/friend.dart';

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
                final participants = roomData['participants'] as List<dynamic>?;

                if (participants != null &&
                    participants.contains(_currentUserNickname)) {
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
                    child: purposes.isEmpty
                        ? Center(
                            // Display "없음" when there are no rooms
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("아직 친구와 설정한 습관이 없어요!",
                                    style: AppTextStyle.body1?.copyWith(
                                        color: const Color.fromRGBO(
                                            153, 159, 155, 1))),
                                Text("지금 만들러 가볼까요?",
                                    style: AppTextStyle.body1?.copyWith(
                                        color: const Color.fromRGBO(
                                            153, 159, 155, 1))),
                                Padding(
                                  padding: const EdgeInsets.only(top: 98),
                                  child: SizedBox(
                                    width: 219,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            16), // BorderRadius 설정
                                        boxShadow: const [
                                          BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.15),
                                            offset: Offset(0, 1),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              133, 232, 173, 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const SizedBox(
                                                  height: 450,
                                                  child: CreateRoom());
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "습관 만들기",
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(14, 15, 14, 1),
                                            fontFamily:
                                                'SpoqaHanSansNeo-Medium',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 100),
                                  child: SizedBox(
                                    width: 219,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            16), // BorderRadius 설정
                                        boxShadow: const [
                                          BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.15),
                                            offset: Offset(0, 1),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    237, 237, 237, 1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            )),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const SizedBox(
                                                  height: 450,
                                                  child: JoinRoomPage());
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "참여하기",
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(14, 15, 14, 1),
                                              fontFamily:
                                                  'SpoqaHanSansNeo-Medium',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
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
                                          roomNumber: int.parse(
                                              roomDocs[roomIndex]
                                                  .id), // Convert to int
                                          nickname: _currentUserNickname,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 55, left: 20),
                                        child: Container(
                                          width: 335,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .background1, // Set the desired RGBA color
                                            borderRadius:
                                                BorderRadius.circular(36),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.15),
                                                offset: Offset(0, 1),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: ListView.builder(
                                            scrollDirection: Axis
                                                .horizontal, // 수평 스크롤을 설정합니다.
                                            itemCount:
                                                filteredParticipants.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final participant =
                                                  filteredParticipants[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    Image.asset(
                                                      'public/images/profilemini.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(participant,
                                                        style:
                                                            AppTextStyle.sub2),
                                                    const SizedBox(width: 25),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Container(
                                          width: 335,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .friendOff, // Set the desired RGBA color
                                            borderRadius:
                                                BorderRadius.circular(36),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.15),
                                                offset: Offset(0, 1),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween, // Right here
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 38),
                                                child: Text(purpose,
                                                    style: AppTextStyle.body2),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 14),
                                                child: Icon(
                                                    Icons.arrow_forward_ios),
                                              ), // Add an arrow icon
                                            ],
                                          ),
                                        ),
                                      ),
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
      } else {
        roomNumbers.add('없음');
      }
    }

    return roomNumbers;
  }
}
