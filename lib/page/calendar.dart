import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/textStyle.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final List<DateTime> _selectedDays = [];
  final Set<int> _disabledMonths = {};
  bool _isSelectedAll = false;

  void _onMonthChanged(int month) {
    _disabledMonths.clear();
    for (int i = 1; i <= 12; i++) {
      if (i != month) _disabledMonths.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          buildWeekArrowButtons(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildWeekdayButtons(),
                TableCalendar(
                  daysOfWeekHeight: 16,
                  rowHeight: 40,
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2023, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  headerVisible: false,
                  selectedDayPredicate: (day) => _selectedDays
                      .any((selectedDay) => isSameDay(selectedDay, day)),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (!_disabledMonths.contains(selectedDay.month)) {
                        DateTime now = DateTime.now();
                        DateTime adjustedSelectedDay = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                            now.hour,
                            now.minute,
                            now.second);

                        if (adjustedSelectedDay.isAfter(DateTime.now()) ||
                            isSameDay(adjustedSelectedDay, DateTime.now())) {
                          int selectedIndex = _selectedDays.indexWhere(
                              (day) => isSameDay(day, adjustedSelectedDay));

                          if (selectedIndex == -1) {
                            _selectedDays.add(adjustedSelectedDay);
                          } else {
                            _selectedDays.removeAt(selectedIndex);
                          }
                        }
                        _focusedDay = focusedDay;
                      }
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    int month = focusedDay.month;
                    _onMonthChanged(month);
                  },
                  daysOfWeekVisible: false,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextFormatter: (date, locale) =>
                        DateFormat.MMMM(locale).format(date),
                  ),
                  calendarStyle: const CalendarStyle(
                    isTodayHighlighted: false,
                    // 다른 달의 날짜 보여주기
                    outsideDaysVisible: true,
                    // 다른 달의 문자 스타일
                    outsideTextStyle: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffE0E2DF)),
                    // 포함되지 않는 날짜 문자 스타일
                    //disabledTextStyle: TextStyle(color: Color(0xffE0E2DF)),
                    // 기본 문자 스타일
                    //defaultTextStyle: TextStyle(),
                    // 날짜 한칸 padding
                    cellPadding: EdgeInsets.zero,
                    cellMargin: EdgeInsets.zero,
                    //todayTextStyle: TextStyle(color: Colors.white)),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                          margin: EdgeInsets.zero,
                          //padding: EdgeInsets.all(8),
                          width: 40,
                          height: 40,
                          color: AppColors.background1,
                          alignment: Alignment.center,
                          child: Center(
                              child: Text(day.day.toString(),
                                  style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo-Medium',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: day.isBefore(DateTime.now())
                                          ? const Color(0xffE0E2DF)
                                          : AppColors.mainText))));
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      if (_selectedDays
                          .any((element) => isSameDay(day, element))) {
                        return Container(
                          decoration:
                              const BoxDecoration(color: AppColors.monthBlue2),
                          alignment: Alignment.center,
                          child: Text(day.day.toString(),
                              style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo-Medium',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: day.isBefore(DateTime.now())
                                      ? const Color(0xffE0E2DF)
                                      : AppColors.mainText)),
                        );
                      } else {
                        if (day.isBefore(DateTime.now())) {
                          return Center(
                            child: Text(day.day.toString(),
                                style:
                                    const TextStyle(color: Color(0xffE0E2DF))),
                          );
                        } else {
                          return Center(child: Text(day.day.toString()));
                        }
                      }
                    },
                  ),
                ),
                selectAllButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 전체 선택 버튼튼
  Widget selectAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Checkbox(
              value: _isSelectedAll,
              onChanged: (bool? value) {
                setState(() {
                  _isSelectedAll = value!;
                  selectAllDates();
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              checkColor: Colors.white,
              activeColor: Colors.lightBlue[200]),
          const Text('전체선택'),
        ],
      ),
    );
  }

  // 전체 날짜 선택 메서드
  void selectAllDates() {
    DateTime firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    int daysInMonth = getDaysInMonth(_focusedDay.month);
    List<DateTime> thisMonthsDates = [];

    for (int i = 0; i < daysInMonth; i++) {
      DateTime currentDay = firstDayOfMonth.add(Duration(days: i));
      if (currentDay.isAfter(DateTime.now()) ||
          isSameDay(currentDay, DateTime.now())) {
        thisMonthsDates.add(currentDay);
      }
    }

    if (_isSelectedAll) {
      _selectedDays.clear();
      _selectedDays.addAll(thisMonthsDates);
    } else {
      _selectedDays.removeWhere((day) => thisMonthsDates.contains(day));
    }
  }

  // 주차 선택 메서드
  void selectDatesByWeek(int weekIndex) {
    _selectedDays.clear();
    DateTime startOfWeek =
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    DateTime firstDayOfNewWeek = startOfWeek.add(Duration(days: 7 * weekIndex));

    for (int i = 0; i < 7; i++) {
      DateTime currentDay = firstDayOfNewWeek.add(Duration(days: i));
      if (currentDay.month == _focusedDay.month &&
          (currentDay.isAfter(DateTime.now()) ||
              isSameDay(currentDay, DateTime.now()))) {
        _selectedDays.add(currentDay);
      }
    }
    setState(() {});
  }

  // 요일 선택 메서드
  void selectDatesByWeekday(int weekdayIndex) {
    DateTime firstVisibleDay =
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    for (int i = weekdayIndex; i <= getDaysInMonth(_focusedDay.month); i += 7) {
      DateTime currentDay = firstVisibleDay.add(Duration(days: i - 1));
      if (!_selectedDays.any((day) => isSameDay(currentDay, day))) {
        _selectedDays.add(currentDay);
      } else {
        _selectedDays.removeWhere((day) => isSameDay(currentDay, day));
      }
    }
    setState(() {});
  }

  int getDaysInMonth(int month) {
    int year = DateTime.now().year;
    int leapYear =
        ((year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))) ? 1 : 0;
    List<int> daysInMonth = [
      31,
      28 + leapYear,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return daysInMonth[month - 1];
  }

  // 주차 선택 버튼
  Widget buildWeekArrowButtons() {
    return Container(
      width: 35, // Set the width to determine the spacing from the left edge
      height: 210,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (int index) {
          return Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1), // shadow direction: bottom right
                ),
              ],
              color: AppColors.background1,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: IconButton(
                onPressed: () {
                  selectDatesByWeek(index);
                },
                iconSize: 25,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.keyboard_arrow_right_rounded),
                color: AppColors.buttonStroke,
              ),
            ),
          );
        }),
      ),
    );
  }

  // 요일 선택 버튼
  Widget buildWeekdayButtons() {
    List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    String month = DateFormat('M월', 'ko_KR').format(_focusedDay);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year,
                        _focusedDay.month - 1, _focusedDay.day);
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_left_rounded),
              ),
              const SizedBox(width: 5),
              Text(month, style: AppTextStyle.head3),
              const SizedBox(width: 5),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year,
                        _focusedDay.month + 1, _focusedDay.day);
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              bool isSelected = _selectedDays
                  .any((selectedDay) => selectedDay.weekday == index);

              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4.0,
                    offset:
                        const Offset(0, 1), // shadow direction: bottom right
                  ),
                ]),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.removeWhere(
                            (selectedDay) => selectedDay.weekday == index);
                      } else {
                        selectDatesByWeekday(index);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.monthBlue2 // Selected color
                        : AppColors.background1,
                    side: BorderSide(color: Colors.transparent),
                    padding: EdgeInsets.zero, // Remove default padding
                    alignment: Alignment.center, // Center align content
                  ),
                  child: Text(
                    day,
                    style: AppTextStyle.body3,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
