import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

class _MonthPageState extends State<MonthPage> {
  double _completionRate = 0;
  void _calculateCompletionRate() async {
    // 선택한 날짜의 연도와 월을 활용하여 시작일과 마지막일 계산
    DateTime firstDayOfMonth =
        DateTime(_selectedDay.year, _selectedDay.month, 1);
    DateTime lastDayOfMonth =
        DateTime(_selectedDay.year, _selectedDay.month + 1, 0);

    // Firestore에서 선택한 달에 해당하는 데이터 가져오기
    QuerySnapshot snapshot = await fireStore
        .collection('habits')
        .where('habitDate', isGreaterThanOrEqualTo: formatDate(firstDayOfMonth))
        .where('habitDate',
            isLessThan: formatDate(lastDayOfMonth.add(const Duration(days: 1))))
        .get();
    // 가져온 데이터 중에서 isDone 값이 true인 목록 찾기
    int doneDataCount =
        snapshot.docs.where((doc) => doc['isDone'] == true).length;
    int totalDataCount = snapshot.docs.length;

    // 선택한 달의 달성률 계산
    if (totalDataCount > 0) {
      setState(() {
        _completionRate = doneDataCount / totalDataCount;
      });
    } else {
      setState(() {
        _completionRate = 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateCompletionRate();
  }

  final int _selectedIndex = 1;
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.pushNamed(context, _routeNames[index]);
    }
  }

  final List<String> _routeNames = [
    '/friend',
    '/home',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 12, bottom: 15),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.mainText,
                size: 30,
              )),
        ),
        //leadingWidth: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text('월별 보기', style: AppTextStyle.bodyMedium),
        ),
        iconTheme: const IconThemeData(color: AppColors.mainText),
        elevation: 10,
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
            const SizedBox(
              height: 14,
            ),
            MonthCompletionRate(
                month: DateFormat('M월', 'ko_KR').format(DateTime.now()),
                ratio: _completionRate)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/friend_off.svg'),
              activeIcon: SvgPicture.asset('public/images/friend_on.svg'),
              label: ''),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/home_off.svg'),
              activeIcon: SvgPicture.asset('public/images/home_on.svg'),
              label: ''),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('public/images/profile_off.svg'),
              activeIcon: SvgPicture.asset('public/images/profile_on.svg'),
              label: ''),
        ],
        fixedColor: AppColors.buttonStroke,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
  final fireStore = FirebaseFirestore.instance;
  double _completionRate = 0;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
    _selectedDay = widget.selectedDay;
  }

  Future<double> calculateCompletionRateForDay(DateTime selectedDate) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('habitDate', isEqualTo: formatDate(selectedDate))
        .get();

    int totalDataCount = snapshot.docs.length;
    int doneDataCount =
        snapshot.docs.where((doc) => doc['isDone'] == true).length;

    if (totalDataCount > 0) {
      return doneDataCount / totalDataCount;
    } else {
      return 0.0;
    }
  }

  final List<Color> completionColors = [
    AppColors.button1, // 0%
    AppColors.monthBlue1, // 1~20%
    AppColors.monthBlue2, // ~40%
    AppColors.monthBlue3, // ~60%
    AppColors.monthBlue4, // ~80%
    AppColors.monthBlue5 // ~100%
  ];

  Color getColor(double completionRate) {
    if (completionRate <= 0.2) {
      return completionColors[0];
    } else if (completionRate <= 0.4) {
      return completionColors[1];
    } else if (completionRate <= 0.6) {
      return completionColors[2];
    } else if (completionRate <= 0.8) {
      return completionColors[3];
    } else if (completionRate < 1.0) {
      return completionColors[4];
    } else {
      return completionColors[5];
    }
  }

  void _calculateCompletionRate() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('habitDate', isGreaterThanOrEqualTo: _focusedDay)
        .where('habitDate',
            isLessThan: _focusedDay.add(const Duration(days: 30)))
        .get();

    int totalDataCount = snapshot.docs.length;
    int doneDataCount =
        snapshot.docs.where((doc) => doc['isDone'] == true).length;

    if (totalDataCount > 0) {
      setState(() {
        _completionRate = doneDataCount / totalDataCount;
      });
    } else {
      setState(() {
        _completionRate = 0.0;
      });
    }
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
          _calculateCompletionRate();
        });
      },
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return FutureBuilder<double>(
            future: calculateCompletionRateForDay(day),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 비동기 계산 중인 동안 표시할 위젯 반환
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(7),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button1,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: AppTextStyle.sub1,
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (snapshot.hasError) {
                // 에러 발생 시 표시할 위젯 반환
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(7),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red, // 에러 상황에 맞게 변경
                  ),
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                );
              } else {
                double completionRate = snapshot.data ?? 0.0;
                Color cellColor = getColor(completionRate);
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(7),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cellColor,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: AppTextStyle.sub1,
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return FutureBuilder<double>(
            future: calculateCompletionRateForDay(day),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 비동기 계산 중인 동안 표시할 위젯 반환
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(7),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button1,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: AppTextStyle.sub1,
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (snapshot.hasError) {
                // 에러 발생 시 표시할 위젯 반환
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(7),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red, // 에러 상황에 맞게 변경
                  ),
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                );
              } else {
                double completionRate = snapshot.data ?? 0.0;
                Color cellColor = getColor(completionRate);
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cellColor,
                    border: Border.all(width: 2, color: AppColors.buttonStroke),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: AppTextStyle.sub1,
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          );
        },
        disabledBuilder: (context, day, focusedDay) {
          return Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(7),
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
        dowBuilder: (context, weekday) {
          return Center(
              child: Text(DateFormat('EE', 'ko_KR').format(weekday),
                  style: AppTextStyle.sub2));
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
  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  int compareDocuments(DocumentSnapshot a, DocumentSnapshot b) {
    bool isDoneA = a['isDone'];
    bool isDoneB = b['isDone'];

    // isDone 값 비교
    if (isDoneA == isDoneB) {
      // isDone 값이 같을 경우 순서 변경 없음
      return 0;
    } else if (isDoneB) {
      // isDone=false 인 문서를 뒤로 이동
      return 1;
    } else {
      // isDone=true 인 문서를 앞으로 이동
      return -1;
    }
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
                  return const Center(
                      child: Text(
                    '데이터 불러오는 중...',
                    style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff999F9B)),
                    textAlign: TextAlign.center,
                  ));
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
                  final documents = snapshot.data!.docs;
                  documents.sort(compareDocuments);

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          documents[index].data()! as Map<String, dynamic>;

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

class MonthCompletionRate extends StatefulWidget {
  final String month;
  final double ratio;
  const MonthCompletionRate(
      {super.key, required this.month, required this.ratio});

  @override
  State<MonthCompletionRate> createState() => _MonthCompletionRateState();
}

class _MonthCompletionRateState extends State<MonthCompletionRate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.3, top: 10, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('이 달의 달성률', style: AppTextStyle.head3),
              const SizedBox(width: 5),
              Text(widget.month,
                  style: const TextStyle(
                      fontFamily: 'SpoqaHanSansNeo-Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff404240))),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border:
                          Border.all(color: AppColors.buttonStroke, width: 1.5),
                    ),
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      percent: widget.ratio,
                      lineHeight: 18,
                      backgroundColor: AppColors.background1,
                      barRadius: const Radius.circular(9),
                      linearGradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xff78E1EF).withOpacity(0.4),
                          const Color(0xff00E1FF).withOpacity(1)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text('${(widget.ratio * 100).toInt()}%',
                  style: AppTextStyle.head2)
            ],
          ),
        ],
      ),
    );
  }
}
