import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soda_4th_hapit/page/tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomPage extends StatefulWidget {
  final int roomNumber;
  final String nickname;

  RoomPage({
    required this.roomNumber,
    required this.nickname,
  });

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int _selectedIndex = 0; // Set the index to the one that should be active
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  TextEditingController _motivationController = TextEditingController();

  Future<void> updateMotivation(String content) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomNumber.toString())
          .update({'motivation': content});
      print('Motivation updated successfully!');
    } catch (error) {
      print('Error updating motivation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

            return Text(
              '$purpose',
              style: const TextStyle(
                  color: Color.fromRGBO(14, 15, 14, 1),
                  fontFamily: 'SpoqaHanSansNeo-Regular',
                  fontSize: 21,
                  fontWeight: FontWeight.w500),
            );
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
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('방이 존재하지 않습니다.'));
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
                  padding: const EdgeInsets.only(right: 200),
                  child: Column(
                    children: participants.map((participant) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 72),
                            child: Text(
                              participant,
                              style: const TextStyle(
                                  color: Color.fromRGBO(14, 15, 14, 1),
                                  fontFamily: 'SpoqaHanSansNeo-Regular',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
                          onPressed: () {},
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
                        onPressed: () {},
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
