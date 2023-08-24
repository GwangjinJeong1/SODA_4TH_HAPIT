import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import './calendar.dart';
import './friend_part.dart';
import '../components/textStyle.dart';
import '../components/colors.dart';

class WithFriend extends StatelessWidget {
  const WithFriend({super.key});
  @override
  Widget build(BuildContext context) {
    DateTime selectedDay = DateTime.now();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 219,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), // BorderRadius 설정
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(133, 232, 173, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await Future.delayed(const Duration(seconds: 0));
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return CreateRoom(selectedDay: selectedDay);
                      },
                    );
                  },
                  child: const Text(
                    "습관 만들기",
                    style: TextStyle(
                      color: Color.fromRGBO(14, 15, 14, 1),
                      fontFamily: 'SpoqaHanSansNeo-Medium',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              child: SizedBox(
                width: 219,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), // BorderRadius 설정
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        )),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return const SizedBox(
                              height: 450, child: JoinRoomPage());
                        },
                      );
                    },
                    child: const Text(
                      "참여하기",
                      style: TextStyle(
                          color: Color.fromRGBO(14, 15, 14, 1),
                          fontFamily: 'SpoqaHanSansNeo-Medium',
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------------- 친구와 함께 방 생성하는 곳----------------------------

class CreateRoom extends StatefulWidget {
  final DateTime selectedDay;
  const CreateRoom({super.key, required this.selectedDay});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _purposeController = TextEditingController();
  DateTime today = DateTime.now();

  List<DateTime> days = [];

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(16), // 여백을 추가합니다.
      height: height * 0.55, // 높이를 조절합니다.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.58,
            child: TextFormField(
              controller: _purposeController,
              style: AppTextStyle.body1,
              cursorColor: AppColors.buttonStroke,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.buttonStroke)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.buttonStroke)),
                hintText: '목록을 입력하세요',
                hintStyle: AppTextStyle.body1,
              ),
            ),
          ),
          SizedBox(
            height: height * 0.35,
            width: width,
            child: Form(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '날짜',
                        style: AppTextStyle.sub1,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        height: 26,
                        child: OutlinedButton(
                          onPressed: () async {
                            final selectedDates = await showModalBottomSheet(
                              context: context,
                              builder: (context) => const CustomCalendar(),
                            );

                            if (selectedDates != null) {
                              setState(() {
                                days = selectedDates;
                              });
                            }
                          }, // 탭 했을 때 캘린더로 선택되도록
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1, color: AppColors.buttonStroke),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Text(
                              days.isEmpty
                                  ? DateFormat('M월 d일 EEEE', 'ko_KR')
                                      .format(DateTime.now())
                                  : DateFormat('M월 d일 EEEE', 'ko_KR')
                                      .format(days[0]),
                              style: AppTextStyle.body3),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: width * 0.27,
                height: 30,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(
                        const Duration(seconds: 0),
                        () => showModalBottomSheet(
                              context: context,
                              builder: (context) => WithFriend(),
                            ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button1,
                  ),
                  child: Text('취소', style: AppTextStyle.body3),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: width * 0.27,
                height: 30,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final habitName = _purposeController.text;
                    final habitDates = days.map((day) {
                      return DateFormat('yyyy-MM-dd').format(day);
                    }).toList();

                    int randomRoomNumber = Random().nextInt(9000) + 1000;
                    String purpose = _purposeController.text;

                    await FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(randomRoomNumber.toString())
                        .set({
                      'roomNumber': randomRoomNumber,
                      'purpose': purpose, // Add the purpose field here
                    });
                    _cleanUp();

                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // 원하는 값으로 변경
                          ),
                          child: CreatedRoomPage(
                              roomNumber: randomRoomNumber,
                              habitName: habitName,
                              habitDates: habitDates),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button2,
                  ),
                  child: Text('완료', style: AppTextStyle.body3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _cleanUp() {
    _purposeController.text = '';
  }
}

//-------------------------이 부분이 팝업 창으로 나와야 하는 곳----------------------
class CreatedRoomPage extends StatefulWidget {
  final int roomNumber;
  final String habitName;
  final List<String> habitDates;
  const CreatedRoomPage(
      {super.key,
      required this.roomNumber,
      required this.habitName,
      required this.habitDates});

  @override
  State<CreatedRoomPage> createState() => _CreatedRoomPageState();
}

class _CreatedRoomPageState extends State<CreatedRoomPage> {
  final TextEditingController _inputController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _inputController.text = widget.roomNumber.toString();
    _checkInput();
  }

  void _checkInput() {
    int enteredNumber = int.tryParse(_inputController.text) ?? -1;

    if (enteredNumber == widget.roomNumber) {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 311,
      height: 230,
      child: Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomNumber.toString())
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('오류가 발생했습니다.'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('방이 존재하지 않습니다.'));
            }

            Map<String, dynamic> roomData =
                snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> participants = roomData['participants'] ?? [];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('public/images/friend_off.svg'),
                  const Padding(
                    padding: EdgeInsets.only(top: 13, bottom: 13),
                    child: Text('초대코드 공유',
                        style: TextStyle(
                            color: Color.fromRGBO(14, 15, 14, 1),
                            fontFamily: 'SpoqaHanSansNeo-Medium',
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                  ),
                  const Text('코드를 통해 친구를 초대하세요.',
                      style: TextStyle(
                          color: Color.fromRGBO(14, 15, 14, 1),
                          fontFamily: 'SpoqaHanSansNeo-Medium',
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                  Padding(
                    padding: const EdgeInsets.only(top: 13, bottom: 13),
                    child: Container(
                      color: const Color.fromRGBO(225, 251, 255, 1),
                      child: SizedBox(
                          width: 108,
                          height: 34,
                          child: Center(
                            child: Text(' ${widget.roomNumber}',
                                style: const TextStyle(
                                    color: Color.fromRGBO(14, 15, 14, 1),
                                    fontFamily: 'SpoqaHanSansNeo-Medium',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(100, 215, 251, 1)),
                      onPressed: () async {
                        if (user != null) {
                          _addFriendHabits(widget.habitName, widget.habitDates);
                          String userNickname;

                          // 현재 사용자의 UID를 이용해 users 컬렉션에서 문서를 가져옴
                          DocumentSnapshot userSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .get();

                          // 가져온 문서에서 'nickname' 필드 값을 가져옴
                          if (userSnapshot.exists) {
                            userNickname = userSnapshot.get('nickname');
                          } else {
                            userNickname = 'Unknown';
                          }

                          participants.add(userNickname);

                          await FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(widget.roomNumber.toString())
                              .update({
                            'participants': participants,
                            'dateList': widget.habitDates,
                          });

                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomPage(
                                  roomNumber: widget.roomNumber,
                                  nickname: userNickname), // 여기서 nickname 전달
                            ),
                          );
                        }
                      },
                      child: const Center(
                        child: Text('확인',
                            style: TextStyle(
                                color: Color.fromRGBO(14, 15, 14, 1),
                                fontFamily: 'SpoqaHanSansNeo-Medium',
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future _addFriendHabits(String habitName, List<String> habitDates) async {
    for (int i = 0; i < habitDates.length; i++) {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('habits').add(
        {
          'habitName': habitName,
          'habitDate': habitDates[i],
          'isDone': false,
          'isAlert': false,
          'isFriend': true,
          'UID': user?.uid,
        },
      );
      String habitId = docRef.id;
      await FirebaseFirestore.instance.collection('habits').doc(habitId).update(
        {'id': habitId},
      );
    }
  }
}

//---------------------------join
class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;
  final List<int> _joinedRooms = []; // 이미 참여한 방 번호를 저장하는 리스트

  Future<void> _checkRoomAndJoin() async {
    setState(() {
      _isLoading = true;
    });

    int enteredNumber = int.tryParse(_inputController.text) ?? -1;

    if (_joinedRooms.contains(enteredNumber)) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 참여한 방입니다.')),
      );
      return;
    }

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(enteredNumber.toString())
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> participants = data['participants'] ?? [];

      User? user = FirebaseAuth.instance.currentUser;

      if (participants.contains(user?.displayName)) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 들어간 방입니다.')),
        );
        return;
      }

      if (data['roomNumber'] == enteredNumber) {
        setState(() {
          _isValid = true;
          _isLoading = false;
        });

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ParticipateRoom(roomNumber: enteredNumber),
              ),
            );
          },
        );
      } else {
        setState(() {
          _isValid = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isValid = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "초대코드 입력",
          style: TextStyle(
            color: Color.fromRGBO(14, 15, 14, 1),
            fontFamily: 'SpoqaHanSansNeo-Medium',
            fontSize: 15,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 30),
          child: SizedBox(
            width: 219,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // BorderRadius 설정
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(214, 220, 220, 1),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(214, 220, 220, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(214, 220, 220, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(214, 220, 220, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 150),
                child: SizedBox(
                  width: 100,
                  height: 34,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16), // BorderRadius 설정
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            (const Color.fromRGBO(237, 237, 237, 1)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color.fromRGBO(14, 15, 14, 1),
                          fontFamily: 'SpoqaHanSansNeo-Medium',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 34,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), // BorderRadius 설정
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: (const Color.fromRGBO(100, 215, 251, 1)),
                    ),
                    onPressed: _isLoading ? null : _checkRoomAndJoin,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            '완료',
                            style: TextStyle(
                              color: Color.fromRGBO(14, 15, 14, 1),
                              fontFamily: 'SpoqaHanSansNeo-Medium',
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_isLoading && !_isValid && _inputController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('유효하지 않은 방 번호입니다.'),
          ),
      ],
    ));
  }
}

//------------------------------------------------------------------------------------------//
//-----------------------------참여하기 이후 초대코드 입력했을 때-----------------------------//
//-----------------------------------------------------------------------------------------//
class ParticipateRoom extends StatefulWidget {
  final int roomNumber;

  const ParticipateRoom({super.key, required this.roomNumber});

  @override
  State<ParticipateRoom> createState() => _ParticipateRoom();
}

class _ParticipateRoom extends State<ParticipateRoom> {
  final TextEditingController _inputController = TextEditingController();
  bool _isValid = false;
  List<String> days = [];

  @override
  void initState() {
    super.initState();
    _inputController.text = widget.roomNumber.toString();
    _checkInput();
    _loadDateList();
  }

  Future<void> _loadDateList() async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomNumber.toString())
        .get();

    if (roomSnapshot.exists) {
      Map<String, dynamic> roomData =
          roomSnapshot.data() as Map<String, dynamic>;
      List<dynamic> dateList = roomData['dateList'] ?? [];

      // 오늘 이후의 날짜들을 찾아 days 리스트에 저장
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (String dateStr in dateList) {
        if ((dateStr == today) || (dateStr.compareTo(today) > 0)) {
          days.add(dateStr);
        }
      }

      setState(() {
        // 데이터가 로드되면 다시 렌더링
      });
    }
  }

  void _checkInput() {
    int enteredNumber = int.tryParse(_inputController.text) ?? -1;

    if (enteredNumber == widget.roomNumber) {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SizedBox(
      width: 311,
      height: 230,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomNumber.toString())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('방이 존재하지 않습니다.'));
          }

          Map<String, dynamic> roomData =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> participants = roomData['participants'] ?? [];
          String purpose = roomData['purpose'] ?? '목표 없음'; // purpose 필드 추가

          String ownerName =
              participants.isNotEmpty ? participants[0] : 'Unknown';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('public/images/friend_off.svg'),
                Padding(
                  padding: const EdgeInsets.only(top: 13, bottom: 13),
                  child: Text('목록확인', style: AppTextStyle.sub1),
                ),
                Text(purpose, style: AppTextStyle.sub2), // purpose를 출력하는 부분
                Padding(
                  padding: const EdgeInsets.only(top: 13, bottom: 13),
                  child: Container(
                    width: 108,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                      color:
                          const Color.fromRGBO(225, 251, 255, 1), // 원하는 배경 색상
                    ),
                    child: Center(
                      child: Text(
                        '방장: $ownerName',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.body3,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), // BorderRadius 설정
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button2, // 원하는 색상으로 변경
                      // 나머지 스타일 속성들...
                    ),
                    onPressed: () async {
                      if (user != null) {
                        String userId;
                        String userNickname;

                        // 현재 사용자의 UID를 이용해 users 컬렉션에서 문서를 가져옴
                        DocumentSnapshot userSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        DocumentSnapshot roomSnapshot = await FirebaseFirestore
                            .instance
                            .collection('rooms')
                            .doc(widget.roomNumber.toString())
                            .get();

                        // 가져온 문서에서 'nickname' 필드 값을 가져옴
                        if (userSnapshot.exists) {
                          userId = userSnapshot.get('userId');
                          userNickname = userSnapshot.get('nickname');
                        } else {
                          userId = 'Unknown';
                          userNickname = 'Unknwon';
                        }

                        participants.add(userId);

                        await FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(widget.roomNumber.toString())
                            .update({
                          'participants': participants,
                        });

                        // 목록 추가
                        _addFriendHabits(roomSnapshot.get('purpose'), days);
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomPage(
                                roomNumber: widget.roomNumber,
                                nickname: userNickname), // 여기서 nickname 전달
                          ),
                        );
                      }
                    },
                    child: Text('확인',
                        textAlign: TextAlign.center, style: AppTextStyle.body3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future _addFriendHabits(String habitName, List<String> habitDates) async {
    for (int i = 0; i < habitDates.length; i++) {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('habits').add(
        {
          'habitName': habitName,
          'habitDate': habitDates[i],
          'isDone': false,
          'isAlert': false,
          'isFriend': true,
          'UID': FirebaseAuth.instance.currentUser?.uid,
        },
      );
      String habitId = docRef.id;
      await FirebaseFirestore.instance.collection('habits').doc(habitId).update(
        {'id': habitId},
      );
    }
  }
}
