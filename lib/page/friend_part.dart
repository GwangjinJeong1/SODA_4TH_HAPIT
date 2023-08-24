import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/colors.dart';
import '../components/text_style.dart';
import 'calendar.dart';

class RoomPage extends StatefulWidget {
  final int roomNumber;
  final String nickname;

  const RoomPage({
    super.key,
    required this.roomNumber,
    required this.nickname,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final int _selectedIndex = 0;
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

  final TextEditingController _motivationController = TextEditingController();

  Future<void> updateMotivation(String content) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomNumber.toString())
          .update({'motivation': content});
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomNumber.toString())
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('오류가 발생했습니다.');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('방이 존재하지 않습니다.');
            }

            Map<String, dynamic> roomData =
                snapshot.data!.data() as Map<String, dynamic>;
            String purpose = roomData['purpose'] ?? '목표 없음';

            return Text(purpose, style: AppTextStyle.bodyMedium);
          },
        ),
        backgroundColor: const Color.fromRGBO(249, 249, 249, 1),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomNumber.toString())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Text('데이터 불러오는 중...',
                    style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff999F9B))));
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('오류가 발생했습니다.',
                    style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.alert)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('방이 존재하지 않습니다.',
                    style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff999F9B))));
          }

          Map<String, dynamic> roomData =
              snapshot.data!.data() as Map<String, dynamic>;

          List<dynamic> participants = roomData['participants'] ?? [];

          // Reorder the list with the current user's nickname at the top
          participants.sort((a, b) {
            if (a == widget.nickname) {
              return -1;
            } else if (b == widget.nickname) {
              return 1;
            }
            return a.compareTo(b);
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 335,
                  height: 70,
                  child: TextFormField(
                    controller: _motivationController,
                    maxLength: 15,
                    decoration: InputDecoration(
                      hintText: roomData['motivation'] ?? "목표달성",
                      filled: true,
                      fillColor: const Color.fromRGBO(244, 244, 244, 1),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(244, 244, 244, 1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(244, 244, 244, 1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(244, 244, 244, 1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintStyle: const TextStyle(
                        color: Color.fromRGBO(14, 15, 14, 1),
                      ),
                      suffixIcon: GestureDetector(
                        child: const Icon(
                          Icons.create_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        onTap: () =>
                            updateMotivation(_motivationController.text),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(right: 170),
                  child: Column(
                    children: [
                      for (String participant in participants)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30, left: 30),
                          child: Row(
                            children: [
                              // SvgPicture.asset('public/images/profile1.svg'),
                              const SizedBox(width: 14), //거리 간격
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(participant)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (snapshot.hasError) {
                                    return Text('오류가 발생했습니다.');
                                  }

                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return Text('사용자 정보 없음');
                                  }

                                  var userNickname = snapshot.data!
                                          .get('nickname') ??
                                      "Unknown"; // Replace "Unknown" with a default value if needed

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userNickname,
                                        style: const TextStyle(
                                          color: Color.fromRGBO(14, 15, 14, 1),
                                          fontFamily: 'SpoqaHanSansNeo-Regular',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 13),
                                      if (participant ==
                                          participants[
                                              0]) // 첫 번째 인덱스인 경우 "방장" 표시
                                        const Text(
                                          '방장',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                153, 159, 155, 1),
                                            fontFamily:
                                                'SpoqaHanSansNeo-Regular',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                for (int i = participants.length; i < 4; i++)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 72),
                    child: Text(
                      "",
                      style: TextStyle(
                        color: Color.fromRGBO(153, 159, 155, 1),
                        fontFamily: 'SpoqaHanSansNeo-Regular',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 128,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                (const Color.fromRGBO(237, 237, 237, 1)),
                          ),
                          onPressed: () async {
                            await Future.delayed(
                                const Duration(seconds: 0),
                                () => showDialog(
                                    context: context,
                                    builder: (context) => DeleteFriendHabit(
                                          roomNumber:
                                              widget.roomNumber.toString(),
                                        )));
                          },
                          child: const Text(
                            "삭제하기",
                            style: TextStyle(
                              color: Color.fromRGBO(14, 15, 14, 1),
                              fontFamily: 'SpoqaHanSansNeo-Medium',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 128,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              (const Color.fromRGBO(100, 215, 251, 1)),
                        ),
                        onPressed: () async {
                          final selectedDate = await showModalBottomSheet(
                            context: context,
                            builder: (context) => const CustomCalendar(),
                          );

                          if (selectedDate != null) {
                            setState(() {});
                          }
                        },
                        child: const Text(
                          "수정하기",
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
                const SizedBox(height: 16),
                Text(
                  '초대코드: ${widget.roomNumber}',
                  style: const TextStyle(
                      color: Color.fromRGBO(64, 66, 64, 1),
                      fontFamily: 'SpoqaHanSansNeo-Regular',
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('public/images/friend_off.svg'),
            activeIcon: SvgPicture.asset('public/images/friend_on.svg'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('public/images/home_off.svg'),
            activeIcon: SvgPicture.asset('public/images/home_on.svg'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('public/images/profile_off.svg'),
            activeIcon: SvgPicture.asset('public/images/profile_on.svg'),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DeleteFriendHabit extends StatefulWidget {
  final String roomNumber;
  const DeleteFriendHabit({super.key, required this.roomNumber});

  @override
  State<DeleteFriendHabit> createState() => _DeleteFriendHabitState();
}

class _DeleteFriendHabitState extends State<DeleteFriendHabit> {
  bool _isDeleting = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return AlertDialog(
      scrollable: true,
      title: SvgPicture.asset('public/images/warning.svg'),
      content: SizedBox(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('정말 이 목록을 삭제하시겠어요?', style: AppTextStyle.sub1),
              Text('삭제하면 친구들의 목록에서도 사라져요.', style: AppTextStyle.sub2),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: width * 0.27,
          height: 30,
          child: ElevatedButton(
            onPressed: _isDeleting
                ? null // Disable button while deleting
                : () async {
                    setState(() {
                      _isDeleting = true; // Set to true to disable button
                    });
                    await _deleteFriendHabits();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button1,
            ),
            child: Text('취소하기', style: AppTextStyle.body3),
          ),
        ),
        SizedBox(
          width: width * 0.27,
          height: 30,
          child: ElevatedButton(
            onPressed: () async {
              await _deleteFriendHabits(); // Await the asynchronous function
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button2,
            ),
            child: Text('삭제하기', style: AppTextStyle.body3),
          ),
        ),
      ],
    );
  }

  Future _deleteFriendHabits() async {
    var collection = FirebaseFirestore.instance.collection('rooms');
    await collection.doc(widget.roomNumber).delete();
  }
}
