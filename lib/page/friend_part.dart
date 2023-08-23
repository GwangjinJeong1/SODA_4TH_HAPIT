import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//----------------------------초대 코드 입력 후 참가--------------------

class CreatedRoomPage extends StatefulWidget {
  final int roomNumber;

  const CreatedRoomPage({super.key, required this.roomNumber});

  @override
  State<CreatedRoomPage> createState() => _CreatedRoomPageState();
}

class _CreatedRoomPageState extends State<CreatedRoomPage> {
  final TextEditingController _inputController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 생성 완료'),
      ),
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
                Text('생성된 방 번호: ${widget.roomNumber}'),
                TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: '4자리 숫자 입력',
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

                      // Pass the 'nickname' parameter when navigating to RoomPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomPage(
                              roomNumber: widget.roomNumber,
                              nickname: userNickname), // Pass 'nickname' here
                        ),
                      );
                    }
                  },
                  child: const Text('입장하기'),
                ),
                if (_isValid)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('입장 가능합니다.'),
                  ),
                if (!_isValid && _inputController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('입장 불가능합니다.'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//--------------방 만듬

class RoomPage extends StatefulWidget {
  final int roomNumber;
  final String nickname; // Add this line to define the 'nickname' parameter

  const RoomPage(
      {super.key,
      required this.roomNumber,
      required this.nickname}); // Add 'nickname' to the constructor

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('방 ${widget.roomNumber}'),
      ),
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
                Text('방 번호: ${widget.roomNumber}'),
                const SizedBox(height: 16),
                const Text('참여자 목록:'),
                Column(
                  children: participants.map((participant) {
                    return Text(participant);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (participants.length < 4) const Text('최대 4명까지만 표시 가능합니다.'),
              ],
            ),
          );
        },
      ),
    );
  }
}
