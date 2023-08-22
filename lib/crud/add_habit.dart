import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soda_4th_hapit/page/calendar.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../components/textStyle.dart';

class AddHabit extends StatefulWidget {
  const AddHabit({super.key});

  @override
  State<AddHabit> createState() => _AddHabitState();
}

class _AddHabitState extends State<AddHabit> {
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController habitDateController = TextEditingController();
  final String today = DateFormat('M월 d일 EEEE', 'ko_KR').format(DateTime.now());
  late bool _isAlert = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(20), // 여백을 추가합니다.
      height: height * 0.55, // 높이를 조절합니다.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.58,
            child: TextFormField(
              controller: habitNameController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: '목록을 입력하세요.',
                hintStyle: TextStyle(
                    fontFamily: 'SpoqaHanSansNeo-Medium',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText2,
                    height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                          value: _isAlert,
                          onChanged: (bool value) {
                            setState(() {
                              _isAlert = value;
                            });
                            if (_isAlert) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const SizedBox();
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
                    final habitDate = habitDateController.text;

                    _addHabits(habitName, habitDate);
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

  Future _addHabits(String habitName, String habitDate) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('habits').add(
      {
        'habitName': habitName,
        'habitDate': habitDate,
        'isDone': false,
        'isAlert': false,
      },
    );
    String habitId = docRef.id;
    await FirebaseFirestore.instance.collection('habits').doc(habitId).update(
      {'id': habitId},
    );
    _clearAll();
  }

  void _clearAll() {
    habitNameController.text = '';
    habitDateController.text = '';
  }
}
