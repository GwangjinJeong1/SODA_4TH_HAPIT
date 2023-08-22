import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soda_4th_habit/components/textStyle.dart';

import '../components/colors.dart';

class DeleteHabit extends StatefulWidget {
  final String habitId, habitName, habitDate;
  const DeleteHabit(
      {super.key,
      required this.habitId,
      required this.habitName,
      required this.habitDate});

  @override
  State<DeleteHabit> createState() => _DeleteHabitState();
}

class _DeleteHabitState extends State<DeleteHabit> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return AlertDialog(
      scrollable: true,
      title: SvgPicture.asset('public/images/warning.svg'),
      content: SizedBox(
        child: Form(
          child: Column(
            children: [
              Text('정말 이 목록을 삭제하시겠어요?', style: AppTextStyle.sub1),
              Text('나가면 그동안의 기록도 사라져요.', style: AppTextStyle.sub2),
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
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button1,
            ),
            child: Text('삭제하기', style: AppTextStyle.body3),
          ),
        ),
        SizedBox(
            width: width * 0.27,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                _deleteHabits();
                Navigator.of(context, rootNavigator: true).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button2,
              ),
              child: Text('취소하기', style: AppTextStyle.body3),
            ))
      ],
    );
  }

  Future _deleteHabits() async {
    var collection = FirebaseFirestore.instance.collection('habits');
    collection.doc(widget.habitId).delete();
  }
}
