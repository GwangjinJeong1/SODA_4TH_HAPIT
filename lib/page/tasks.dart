import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soda_4th_habit/page/month.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/textStyle.dart';
import '../crud/add_habit.dart';
import '../crud/update_habit.dart';
import '../components/colors.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final fireStore = FirebaseFirestore.instance;
  DateTime _selectedDay = DateTime.now();
  int _totalDataCount = 0;
  int _doneDataCount = 0;
  double _completionRate = 0;

  @override
  void initState() {
    super.initState();
    _updateCompletionRate();
  }

  void isDone(String habitId, bool newValue) async {
    await fireStore
        .collection('habits')
        .doc(habitId)
        .update({'isDone': newValue});
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  void _calculateCompletionRate(List<DocumentSnapshot> documents) {
    _totalDataCount = documents.length;
    _doneDataCount = documents.where((doc) => doc['isDone'] == true).length;
    if (_totalDataCount > 0) {
      _completionRate = _doneDataCount / _totalDataCount;
    } else {
      _completionRate = 0;
    }
  }

  void _updateCompletionRate() async {
    List<DocumentSnapshot> documents = await fireStore
        .collection('habits')
        .where('habitDate', isEqualTo: formatDate(_selectedDay))
        .get()
        .then((snapshot) => snapshot.docs);

    _calculateCompletionRate(documents);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('습관목록', style: AppTextStyle.head3),
            ],
          ),
          const SizedBox(height: 15),
          WeekCalendar(
            selectedDay: _selectedDay, // WeekCalendar에 selectedDay 추가
            onDaySelected: (selectedDay) {
              setState(() {
                _selectedDay = selectedDay; // 선택된 날짜 업데이트
              });
              _updateCompletionRate();
            },
          ),
          Container(
            width: 375,
            height: 230,
            margin: const EdgeInsets.all(10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: fireStore
                  .collection('habits')
                  .where("habitDate", isEqualTo: formatDate(_selectedDay))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                      width: 75,
                      height: 75,
                      child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    '오늘 설정한 습관이 없어요!\n지금 만들러 가볼까요?',
                    style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff999F9B)),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  _calculateCompletionRate(documents);
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return Container(
                        width: 335,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36.0),
                          color: data['isDone']
                              ? AppColors.aloneOn
                              : AppColors.aloneOff,
                          boxShadow: [
                            data['isDone']
                                ? BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4.0,
                                    offset: const Offset(
                                        0, 4), // shadow direction: bottom right
                                  )
                                : BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4.0,
                                    offset: const Offset(
                                        0, 1), // shadow direction: bottom right
                                  ),
                          ],
                        ),
                        child: Center(
                          child: ListTile(
                            leading: Checkbox(
                              value: data['isDone'],
                              onChanged: (value) {
                                data['isDone'] = value;

                                isDone(document.id, value!);

                                _updateCompletionRate();
                              },
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
                            title: Text(data['habitName'],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: data['isDone']
                                        ? Colors.grey
                                        : Colors.black)),
                            onTap: () {
                              Future.delayed(
                                const Duration(seconds: 0),
                                () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      UpdateHabit(habitData: data),
                                ),
                              );
                            },
                            dense: true,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          const AddListButton(),
          CompletionRate(
              date: DateFormat('M월 d일', 'ko_KR').format(_selectedDay),
              ratio: _completionRate)
        ],
      ),
    );
  }
}

class WeekCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  const WeekCalendar(
      {super.key, required this.selectedDay, required this.onDaySelected});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();

class _WeekCalendarState extends State<WeekCalendar> {
  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      headerVisible: false,
      daysOfWeekVisible: false,
      rowHeight: 70,
      calendarFormat: CalendarFormat.week,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 7, 1),
      lastDay: DateTime.utc(2023, 10, 31),
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
        cellMargin: EdgeInsets.zero,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          final dowText =
              DateFormat(DateFormat.ABBR_WEEKDAY, 'ko_KR').format(date);
          final dayText = date.day.toString();

          return Center(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.background1,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dowText,
                      style: AppTextStyle.sub2,
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      dayText,
                      style: AppTextStyle.body1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        selectedBuilder: (context, date, events) {
          final dowText =
              DateFormat(DateFormat.ABBR_WEEKDAY, 'ko_KR').format(date);
          final dayText = date.day.toString();

          return Center(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.background2,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 1),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dowText,
                      style: AppTextStyle.sub2,
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      dayText,
                      style: AppTextStyle.body1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddListButton extends StatelessWidget {
  const AddListButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 70,
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10, 17, 9, 17),
                    backgroundColor: AppColors.friendPlus,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 7),
                child: Row(
                  children: [
                    SvgPicture.asset('public/images/friend_off.svg',
                        width: 41, height: 36.5),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('친구와 함께', style: AppTextStyle.sub1),
                        Text('습관 만들기', style: AppTextStyle.sub3),
                      ],
                    ),
                  ],
                )),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 160,
            height: 70,
            child: ElevatedButton(
                onPressed: () {
                  Future.delayed(
                    const Duration(seconds: 0),
                    () => showModalBottomSheet(
                      context: context,
                      builder: (context) => const AddHabit(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(19, 17, 34, 17),
                    backgroundColor: AppColors.alonePlus,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 7),
                child: Row(
                  children: [
                    SvgPicture.asset('public/images/alone.svg',
                        width: 28, height: 28),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나만의', style: AppTextStyle.sub1),
                        Text('습관 만들기', style: AppTextStyle.sub3),
                      ],
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class CompletionRate extends StatefulWidget {
  final String date;
  final double ratio;
  const CompletionRate({super.key, required this.date, required this.ratio});

  @override
  State<CompletionRate> createState() => _CompletionRateState();
}

class _CompletionRateState extends State<CompletionRate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.3, top: 10, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('오늘의 달성률', style: AppTextStyle.head3),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                child: SizedBox(
                  width: 139,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MonthPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19)),
                        elevation: 0),
                    child: Row(children: [
                      Text('월별 보기', style: AppTextStyle.body2),
                      //const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_right_rounded,
                          color: AppColors.bodyText1, size: 30),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          Text(widget.date,
              style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo-Regular',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff404240))),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    percent: widget.ratio,
                    lineHeight: 10,
                    backgroundColor: AppColors.background1,
                    progressColor: Colors.lightBlueAccent,
                    width: 200,
                    // animation: true,
                    // animationDuration: 1000,
                  ),
                ),
              ),
              //const SizedBox(width: 5),
              Text('${widget.ratio * 100}%', style: AppTextStyle.head2)
            ],
          ),
        ],
      ),
    );
  }
}
