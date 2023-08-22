import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soda_4th_habit/components/textStyle.dart';
import 'dart:ui';
import '../components/colors.dart';

class SetAlert extends StatefulWidget {
  final String habitId;
  const SetAlert({super.key, required this.habitId});

  @override
  State<SetAlert> createState() => _SetAlertState();
}

class _SetAlertState extends State<SetAlert> {
  final fireStore = FirebaseFirestore.instance;
  final DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('알림 시간'),
                ],
              ),
              const SizedBox(height: 15),
              const Expanded(
                child: TimePicker(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button1,
                    ),
                    child: Text('취소', style: AppTextStyle.body3),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      fireStore
                          .collection('habits')
                          .doc(widget.habitId)
                          .update({'alertTime': _dateTime, 'isAlert': true});
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button2,
                    ),
                    child: Text('완료', style: AppTextStyle.body3),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class TimePicker extends StatefulWidget {
  const TimePicker({super.key});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late FixedExtentScrollController _ampmController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  final DateTime _dateTime = DateTime.now();
  @override
  void initState() {
    super.initState();
    _ampmController =
        FixedExtentScrollController(initialItem: _dateTime.hour ~/ 12);
    _hourController =
        FixedExtentScrollController(initialItem: _dateTime.hour % 12 - 1);
    _minuteController =
        FixedExtentScrollController(initialItem: _dateTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.center,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width - 70,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.friendPlus,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildCupertinoPicker(['오전', '오후'], _ampmController, (index) {}),
          const SizedBox(width: 24),
          buildCupertinoPicker(
              List.generate(12, (hour) => '${hour + 1}'.padLeft(2, '0')),
              _hourController,
              (hour) {}),
          const SizedBox(width: 17),
          const Text(':',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(width: 7),
          buildCupertinoPicker(
              List.generate(60, (minute) => '$minute'.padLeft(2, '0')),
              _minuteController,
              (minute) {}),
        ],
      ),
    ]);
  }

  Widget buildCupertinoPicker(
      List<String> items,
      FixedExtentScrollController controller,
      Function(int) onSelectedItemChanged) {
    return SizedBox(
      width: 75,
      height: MediaQuery.of(context).size.height - 100,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 70,
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: null,
        children: items
            .map((item) => Center(
                child: Text(item,
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff404240)))))
            .toList(),
      ),
    );
  }
}
