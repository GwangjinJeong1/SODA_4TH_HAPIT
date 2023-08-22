import 'package:flutter/material.dart';
import 'package:soda_4th_habit/components/colors.dart';
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
                  rowHeight: 25,
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2023, 7, 1),
                  lastDay: DateTime.utc(2023, 10, 31),
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
                      selectedDecoration:
                          BoxDecoration(color: Color(0xff5C6BC0)), // 선택된 날짜 색깔
                      outsideDaysVisible: true,
                      // 다른 달의 날짜 보여주기
                      outsideTextStyle: TextStyle(color: Color(0xffAEAEAE)),
                      // 다른 달의 문자 스타일
                      disabledTextStyle: TextStyle(color: Color(0xffBFBFBF)),
                      // 포함되지 않는 날짜 문자 스타일
                      defaultTextStyle: TextStyle(),
                      // 기본 문자 스타일
                      cellPadding: EdgeInsets.all(1),
                      // 날짜 한칸 padding
                      cellMargin: EdgeInsets.zero,
                      todayTextStyle: TextStyle(color: Colors.white)),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                          margin: EdgeInsets.zero,
                          width: 30,
                          height: 30,
                          color: Colors.amber,
                          child: Center(
                              child: Text(day.day.toString(),
                                  style: TextStyle(
                                      color: day.isBefore(DateTime.now())
                                          ? Colors.grey
                                          : Colors.black))));
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      if (_selectedDays
                          .any((element) => isSameDay(day, element))) {
                        return Container(
                          decoration:
                              const BoxDecoration(color: Colors.lightGreen),
                          alignment: Alignment.center,
                          child: Text(day.day.toString(),
                              style: TextStyle(
                                  color: day.isBefore(DateTime.now())
                                      ? Colors.grey
                                      : Colors.black)),
                        );
                      } else {
                        if (day.isBefore(DateTime.now())) {
                          return Center(
                            child: Text(day.day.toString(),
                                style: const TextStyle(color: Colors.grey)),
                          );
                        } else {
                          return Center(child: Text(day.day.toString()));
                        }
                      }
                    },
                  ),
                ),
                selectAllButton(),
                //buildWeekArrowButtons(),
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
    return Column(
      children: [
        const SizedBox(height: 80),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (int index) {
            return IconButton(
              onPressed: () {
                selectDatesByWeek(index);
              },
              icon: const Icon(Icons.keyboard_arrow_right_rounded),
            );
          }),
        ),
      ],
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
              Text(month,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              return SizedBox(
                width: 30,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    selectDatesByWeekday(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background1,
                    elevation: 2,
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(color: Colors.black),
                    ),
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