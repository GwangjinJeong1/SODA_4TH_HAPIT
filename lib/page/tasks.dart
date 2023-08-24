import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './month.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/textStyle.dart';
import '../crud/add_habit.dart';
import '../crud/update_habit.dart';
import '../components/colors.dart';
import './friend.dart';

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

  int compareDocuments(DocumentSnapshot a, DocumentSnapshot b) {
    bool isDoneA = a['isDone'];
    bool isDoneB = b['isDone'];

    // isDone 값 비교
    if (isDoneA == isDoneB) {
      // isDone 값이 같을 경우 순서 변경 없음
      return 0;
    } else if (isDoneA) {
      // isDone=true 인 문서를 뒤로 이동
      return 1;
    } else {
      // isDone=false 인 문서를 앞으로 이동
      return -1;
    }
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
          const SizedBox(height: 10),
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
            width: 390,
            height: 230,
            margin: const EdgeInsets.all(10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: fireStore
                  .collection('habits')
                  .where("habitDate", isEqualTo: formatDate(_selectedDay))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('데이터 불러오는 중...',
                          style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo-Medium',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff999F9B))));
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
                  documents.sort(compareDocuments);

                  _calculateCompletionRate(documents);
                  return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = documents[index];
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
                                      offset: const Offset(0, 4),
                                    )
                                  : BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 1),
                                    ),
                            ],
                          ),
                          child: Center(
                            child: ListTile(
                              leading: Checkbox(
                                value: data['isDone'],
                                onChanged: (value) {
                                  setState(() {
                                    data['isDone'] = value;
                                  });

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
                                      fontFamily: 'SpoqaHanSansNeo-Regular',
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
                      });
                }
              },
            ),
          ),
          AddListButton(updateCompletionRate: _updateCompletionRate),
          CompletionRate(
              date: DateFormat('M월 d일', 'ko_KR').format(_selectedDay),
              ratio: _completionRate)
        ],
      ),
    );
  }
}

DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();
String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

class WeekCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  const WeekCalendar(
      {super.key, required this.selectedDay, required this.onDaySelected});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      headerVisible: false,
      daysOfWeekVisible: false,
      rowHeight: 75,
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
              height: 65,
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
              width: 38,
              height: 65,
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
  final Function updateCompletionRate;
  const AddListButton({super.key, required this.updateCompletionRate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 70,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]),
            child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return const WithFriend();
                      });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(10, 17, 9, 15),
                  backgroundColor: AppColors.friendPlus,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          AppColors.buttonStroke,
                          BlendMode.srcIn, // 색상을 이미지에 블렌드하는 방식
                        ),
                        child: SvgPicture.asset(
                          'public/images/friend_off.svg', // 사용하려는 SVG 이미지의 경로로 변경
                        )),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('친구와 함께', style: AppTextStyle.sub1),
                        Text('습관 만들기', style: AppTextStyle.sub4),
                      ],
                    ),
                  ],
                )),
          ),
          const SizedBox(width: 11),
          Container(
            width: 160,
            height: 70,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]),
            child: ElevatedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(seconds: 0));
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return AddHabit(
                        selectedDay: _selectedDay,
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      updateCompletionRate();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(19, 17, 34, 15),
                  backgroundColor: AppColors.alonePlus,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
                        Text('습관 만들기', style: AppTextStyle.sub4),
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
              SizedBox(
                width: 125,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MonthPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 15),
                    backgroundColor: AppColors.button1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center align the children
                    children: [
                      Text('월별 보기', style: AppTextStyle.body2),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: AppColors.bodyText1,
                        size: 30,
                      )
                    ],
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
          const SizedBox(height: 22),
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
