import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do/page/calendar.dart';
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
  final TextEditingController habitDescController = TextEditingController();
  final String today = DateFormat('M월 d일 EEEE', 'ko_KR').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    habitNameController.text = widget.habitData['habitName'];
    habitDescController.text = widget.habitData['habitDate'];

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
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: widget.habitData['habitName'],
                    hintStyle: const TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText2,
                        height: 1.5),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
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
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.35,
            width: width,
            child: Form(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
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
                          onPressed: () {
                            Future.delayed(
                              const Duration(seconds: 0),
                              () => showModalBottomSheet(
                                context: context,
                                builder: (context) => const CustomCalendar(),
                              ),
                            );
                          }, // 탭 했을 때 캘린더로 선택되도록
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1, color: AppColors.buttonStroke),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Text(today, style: AppTextStyle.body3),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
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
              SizedBox(
                width: width * 0.27,
                height: 30,
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
              SizedBox(
                width: width * 0.27,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    final habitName = habitNameController.text;
                    final habitDate = habitDescController.text;

                    _updateTasks(habitName, habitDate);
                    Navigator.of(context, rootNavigator: true).pop();
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

  Future _updateTasks(String habitName, String habitDate) async {
    var collection = FirebaseFirestore.instance.collection('habits');
    collection
        .doc(widget.habitData['id'])
        .update({'habitName': habitName, 'habitDate': habitDate});
  }
}
