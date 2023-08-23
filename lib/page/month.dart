import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/textStyle.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/colors.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

final fireStore = FirebaseFirestore.instance;
DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();

class _MonthPageState extends State<MonthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppColors.mainText,
            )),
        title: Text('월별 보기', style: AppTextStyle.bodyMedium),
        iconTheme: const IconThemeData(color: AppColors.mainText),
        elevation: 2,
        backgroundColor: AppColors.background1,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 17, top: 16, right: 16),
        child: Column(
          children: [
            Text('${_focusedDay.month}월', style: AppTextStyle.head3),
            const SizedBox(height: 23),
            MonthCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
            ),
            const SizedBox(height: 17),
            HabitCard(
              selectedDay: _selectedDay,
            ),
          ],
        ),
      ),
    );
  }
}

class MonthCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  const MonthCalendar(
      {super.key, required this.selectedDay, required this.onDaySelected});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
    _selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      headerVisible: false,
      rowHeight: 50,
      daysOfWeekHeight: 25,
      calendarFormat: CalendarFormat.month,
      focusedDay: _focusedDay,
      firstDay: DateTime(_selectedDay.year, _selectedDay.month),
      lastDay: DateTime(_selectedDay.year, _selectedDay.month + 1, 0),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          widget.onDaySelected(selectedDay);
        });
      },
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(7),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.button1),
              child: Text(
                day.day.toString(),
                style: AppTextStyle.sub1,
                textAlign: TextAlign.center,
              ));
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(5),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.button1,
                border: Border.all(width: 2, color: AppColors.buttonStroke),
              ),
              child: Text(
                day.day.toString(),
                style: AppTextStyle.sub1,
                textAlign: TextAlign.center,
              ));
        },
        disabledBuilder: (context, day, focusedDay) {
          return Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background2,
              ),
              child: Text(
                day.day.toString(),
                style: const TextStyle(
                    fontFamily: 'SpoqaHanSansNeo-Medium',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffE0E2DF)),
                textAlign: TextAlign.center,
              ));
        },
      ),
    );
  }
}

class HabitCard extends StatefulWidget {
  final DateTime selectedDay;
  const HabitCard({super.key, required this.selectedDay});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late final DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9), color: AppColors.background2),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('M월 d일', 'ko_KR').format(widget.selectedDay),
                    style: AppTextStyle.sub1),
                Text(DateFormat('EEEE', 'ko_KR').format(widget.selectedDay),
                    style: AppTextStyle.sub2),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 25, top: 10, bottom: 20, right: 15),
            width: 245,
            child: FutureBuilder<QuerySnapshot>(
              future: fireStore
                  .collection('habits')
                  .where("habitDate",
                      isEqualTo:
                          DateFormat('yyyy-MM-dd').format(widget.selectedDay))
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      '아직 습관을 만들지 않았어요',
                      style: TextStyle(
                          fontFamily: 'SpoqaHanSansNeo-Medium',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff999F9B)),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          docs[index].data()! as Map<String, dynamic>;

                      return SizedBox(
                        width: 150,
                        height: 25,
                        child: Center(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            leading: Checkbox(
                              value: data['isDone'],
                              onChanged: (value) {},
                              activeColor: AppColors.monthBlue4,
                              side: MaterialStateBorderSide.resolveWith(
                                (states) => BorderSide(
                                    width: 1.0,
                                    color: data['isDone']
                                        ? Colors.transparent
                                        : AppColors.buttonStroke),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            horizontalTitleGap: 1,
                            title: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Text(data['habitName'],
                                  style: AppTextStyle.sub2),
                            ),
                            dense: true,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ScrollBlur extends StatelessWidget {
  const ScrollBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 247,
      height: 41,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.0,
              0.4792
            ],
            colors: [
              Colors.transparent,
              Color(0xFFF4F4F4),
            ]),
      ),
    );
  }
}
