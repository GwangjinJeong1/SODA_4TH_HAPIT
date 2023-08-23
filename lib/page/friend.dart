import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soda_4th_hapit/page/friend_part.dart';

class WithFriend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 219,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(133, 232, 173, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateRoom();
                    },
                  );
                },
                child:
                    const Text("습관 만들기", style: TextStyle(color: Colors.black)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              child: SizedBox(
                width: 219,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return JoinRoomPage();
                      },
                    );
                  },
                  child:
                      const Text("참여하기", style: TextStyle(color: Colors.black)),
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
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _purposeController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 277,
              child: TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: "목록을 입력하세요.",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                int randomRoomNumber = Random().nextInt(9000) + 1000;
                String purpose = _purposeController.text;

                await FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(randomRoomNumber.toString())
                    .set({
                  'roomNumber': randomRoomNumber,
                  'purpose': purpose, // Add the purpose field here
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
                        child: CreatedRoomPage(roomNumber: randomRoomNumber),
                      ),
                    );
                  },
                );
              },
              child: const Text("방 만들기"),
            ),
          ],
        ),
      ),
    );
  }
}

//-------------------------이 부분이 팝업 창으로 나와야 하는 곳----------------------
class CreatedRoomPage extends StatefulWidget {
  final int roomNumber;

  CreatedRoomPage({required this.roomNumber});

  @override
  _CreatedRoomPageState createState() => _CreatedRoomPageState();
}

class _CreatedRoomPageState extends State<CreatedRoomPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isValid = false;
  final TextEditingController _nicknameController =
      TextEditingController(); // 여기에 추가

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

            User? user = FirebaseAuth.instance.currentUser;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('public/images/friend_off.svg'),
                  const Padding(
                    padding: EdgeInsets.only(top: 13, bottom: 13),
                    child: Text('초대코드 공유'),
                  ),
                  const Text('코드를 통해 친구를 초대하세요.'),
                  Padding(
                    padding: const EdgeInsets.only(top: 13, bottom: 13),
                    child: Container(
                      color: const Color.fromRGBO(225, 251, 255, 1),
                      child: SizedBox(
                          width: 108,
                          height: 34,
                          child: Center(
                            child: Text(' ${widget.roomNumber}',
                                textAlign: TextAlign.center),
                          )),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (user != null) {
                        String userNickname;

                        // 현재 사용자의 UID를 이용해 users 컬렉션에서 문서를 가져옴
                        DocumentSnapshot userSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(user.uid)
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
                    child: const SizedBox(
                      width: 100,
                      height: 34,
                      child: Center(
                        child: Text('확인', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  // if (_isValid)
                  //   const Padding(
                  //     padding: EdgeInsets.all(16.0),
                  //     child: Text('입장 가능합니다.'),
                  //   ),
                  // if (!_isValid && _inputController.text.isNotEmpty)
                  //   const Padding(
                  //     padding: EdgeInsets.all(16.0),
                  //     child: Text('입장 불가능합니다.'),
                  //   ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WithFriend(),
  ));
}

//---------------------------join
class JoinRoomPage extends StatefulWidget {
  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  TextEditingController _inputController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  Future<void> _checkRoomAndJoin() async {
    setState(() {
      _isLoading = true;
    });

    int enteredNumber = int.tryParse(_inputController.text) ?? -1;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(enteredNumber.toString())
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (data['roomNumber'] == enteredNumber) {
        setState(() {
          _isValid = true;
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParticipateRoom(
              roomNumber: enteredNumber,
            ),
          ),
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("초대코드 입력"),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: SizedBox(
                width: 219,
                height: 50,
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(214, 220, 220, 1),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(214, 220, 220, 1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 250),
                  child: SizedBox(
                    width: 100,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('취소'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkRoomAndJoin,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('완료'),
                  ),
                ),
              ],
            ),
            if (!_isLoading && !_isValid && _inputController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('유효하지 않은 방 번호입니다.'),
              ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------------------//
//-----------------------------참여하기 이후 초대코드 입력했을 때-----------------------------//
//-----------------------------------------------------------------------------------------//
class ParticipateRoom extends StatefulWidget {
  final int roomNumber;

  ParticipateRoom({required this.roomNumber});

  @override
  _ParticipateRoom createState() => _ParticipateRoom();
}

class _ParticipateRoom extends State<ParticipateRoom> {
  final TextEditingController _inputController = TextEditingController();
  bool _isValid = false;
  final TextEditingController _nicknameController =
      TextEditingController(); // 여기에 추가

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
            String purpose = roomData['purpose'] ?? '목표 없음'; // purpose 필드 추가

            User? user = FirebaseAuth.instance.currentUser;

            String ownerName =
                participants.isNotEmpty ? participants[0] : 'Unknown';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('public/images/friend_off.svg'),
                  const Padding(
                    padding: EdgeInsets.only(top: 13, bottom: 13),
                    child: Text('목록확인'),
                  ),
                  Text(purpose), // purpose를 출력하는 부분
                  Padding(
                    padding: const EdgeInsets.only(top: 13, bottom: 13),
                    child: Container(
                      color: const Color.fromRGBO(225, 251, 255, 1),
                      child: SizedBox(
                          width: 108,
                          height: 34,
                          child: Center(
                            child: Text('방장: $ownerName',
                                textAlign: TextAlign.center),
                          )),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (user != null) {
                        String userNickname;

                        // 현재 사용자의 UID를 이용해 users 컬렉션에서 문서를 가져옴
                        DocumentSnapshot userSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(user.uid)
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
                    child: const SizedBox(
                      width: 100,
                      height: 34,
                      child: Center(
                        child: Text('확인', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  // if (_isValid)
                  //   const Padding(
                  //     padding: EdgeInsets.all(16.0),
                  //     child: Text('입장 가능합니다.'),
                  //   ),
                  // if (!_isValid && _inputController.text.isNotEmpty)
                  //   const Padding(
                  //     padding: EdgeInsets.all(16.0),
                  //     child: Text('입장 불가능합니다.'),
                  //   ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
