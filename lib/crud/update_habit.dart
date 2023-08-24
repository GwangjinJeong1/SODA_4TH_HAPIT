import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soda_4th_hapit/page/calendar.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../components/textStyle.dart';
import './delete_habit.dart';
import './set_time.dart';

class UpdateHabit extends StatefulWidget {
  final Map<String, dynamic> habitData;
  const UpdateHabit({super.key, required this.habitData});

  @override
  State<UpdateHabit> createState() => _UpdateHabitState();
}

class _UpdateHabitState extends State<UpdateHabit> {
  final fireStore = FirebaseFirestore.instance;
  final TextEditingController habitNameController = TextEditingController();

  DateTime today = DateTime.now();
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
          Row(
            children: [
              SizedBox(
                width: width * 0.58,
                child: TextFormField(
                  controller: habitNameController,
                  style: AppTextStyle.body1,
                  cursorColor: AppColors.buttonStroke,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.buttonStroke)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.buttonStroke)),
                    hintText: widget.habitData['habitName'],
                    hintStyle: AppTextStyle.body1,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: PopupMenuButton<String>(
                    icon: SvgPicture.asset('public/images/trashcan.svg'),
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: '오늘',
                          child: Text('오늘'),
                        ),
                        const PopupMenuItem<String>(
                          value: '이번 주',
                          child: Text('이번 주'),
                        ),
                        const PopupMenuItem<String>(
                          value: '향후',
                          child: Text('향후'),
                        ),
                      ];
                    },
                    onSelected: (String value) async {
                      await Future.delayed(
                        const Duration(seconds: 0),
                        () => showDialog(
                          context: context,
                          builder: (context) => DeleteHabit(
                            habitId: widget.habitData['id'],
                            habitName: widget.habitData['habitName'],
                            habitDate: widget.habitData['habitDate'],
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  )),
            ],
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
                            final selectedDate = await showModalBottomSheet(
                              context: context,
                              builder: (context) => const CustomCalendar(),
                            );

                            if (selectedDate != null) {
                              setState(() {
                                today = selectedDate;
                              });
                            }
                          }, // 탭 했을 때 캘린더로 선택되도록
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1, color: AppColors.buttonStroke),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Text(
                              DateFormat('M월 d일 EEEE', 'ko_KR').format(today),
                              style: AppTextStyle.body3),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '알림',
                        style: AppTextStyle.sub1,
                      ),
                      const Spacer(),
                      Switch(
                          activeColor: AppColors.button2,
                          activeTrackColor: AppColors.monthBlue2,
                          inactiveThumbColor: AppColors.bodyText2,
                          inactiveTrackColor: AppColors.button1,
                          value: widget.habitData['isAlert'],
                          onChanged: (bool value) {
                            setState(() {
                              widget.habitData['isAlert'] = value;
                            });
                            if (widget.habitData['isAlert']) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SetAlert(
                                      habitId: widget.habitData['id'],
                                    );
                                  });
                            }
                          }),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
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
                    Navigator.of(context, rootNavigator: true).pop();
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
                    final habitName = habitNameController.text;
                    final habitDate = DateFormat('yyyy-MM-dd').format(today);

                    await _updateHabits(habitName, habitDate);

                    Navigator.of(context).pop();
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

  Future _updateHabits(String habitName, String habitDate) async {
    var collection = FirebaseFirestore.instance.collection('habits');
    collection
        .doc(widget.habitData['id'])
        .update({'habitName': habitName, 'habitDate': habitDate});
  }
}
