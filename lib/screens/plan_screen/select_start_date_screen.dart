import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectStartDateScreen extends StatefulWidget {
  const SelectStartDateScreen({super.key});

  @override
  State<SelectStartDateScreen> createState() => _SelectStartDateScreenState();
}

class _SelectStartDateScreenState extends State<SelectStartDateScreen> {
  DateTime? _focusedDay;
  DateTime? _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late ComboDate _selectedComboDate;
  String? _startTime;

  _onDaySelected(DateTime selectDay, DateTime focusDay) {
    if (!isSameDay(_selectedDate, selectDay)) {
      setState(() {
        _selectedDate = selectDay;
        _focusedDay = focusDay;
        _rangeStart = _selectedDate;
        _rangeEnd = _selectedDate!
            .add(Duration(days: _selectedComboDate.numberOfDay - 1));
        sharedPreferences.setString('plan_start_date', _rangeStart.toString());
        sharedPreferences.setString('plan_end_date', _rangeEnd.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedComboDate =
        listComboDate[sharedPreferences.getInt('plan_combo_date')!];
    final startDate = sharedPreferences.getString('plan_start_date');
    _startTime = sharedPreferences.getString('plan_start_time');

    if (startDate != null) {
      setState(() {
        handleChangeComboDate();
        _selectedDate = DateTime.parse(startDate);
        _rangeStart = _selectedDate;
        _rangeEnd = _selectedDate!
            .add(Duration(days: _selectedComboDate.numberOfDay - 1));
        _focusedDay = _rangeStart;
        sharedPreferences.setString('plan_end_date', _rangeEnd.toString());
      });
    }
  }

  handleChangeComboDate() {
    final isChanged = sharedPreferences.getBool('plan_is_change');
    if (isChanged == null || !isChanged) {
      setState(() {
        final initialDateTime = DateFormat.Hm()
            .parse(sharedPreferences.getString('plan_start_time')!);
        final startTime =
            DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
        final arrivedTime = startTime.add(Duration(
            seconds:
                (sharedPreferences.getDouble('plan_duration')! * 3600).ceil()));
        if (arrivedTime.isAfter(DateTime(0, 0, 0, 6, 0))) {
          _selectedComboDate = listComboDate.firstWhere(
              (element) => element.duration == _selectedComboDate.duration + 2);
          sharedPreferences.setInt(
              'plan_combo_date', _selectedComboDate.id - 1);
          sharedPreferences.setBool("plan_is_change", true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Tổng thời gian chuyến đi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2.h,
          ),
          const Text(
            '(Bao gồm thời gian di chuyển từ địa điểm xuất phát)',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            '${_selectedComboDate.numberOfDay} ngày ${_selectedComboDate.numberOfNight} đêm',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (_selectedDate != null)
            Text(
              '${_startTime} ${_rangeStart!.day}/${_rangeStart!.month}/${_rangeStart!.year} - ${_rangeEnd!.day}/${_rangeEnd!.month}/${_rangeEnd!.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          SizedBox(
            height: 2.h,
          ),
          const Text(
            'Thời gian trải nghiệm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TableCalendar(
              locale: 'vi_VN',
              focusedDay: _focusedDay!,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              calendarFormat: _calendarFormat,
              onDaySelected: _onDaySelected,
              firstDay: DateTime.now(),
              lastDay: DateTime(2025),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarStyle: CalendarStyle(
                  todayTextStyle: const TextStyle(color: Colors.black),
                  rangeStartDecoration: const BoxDecoration(
                      shape: BoxShape.circle, color: primaryColor),
                  selectedDecoration: const BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle),
                  todayDecoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.transparent),
                  rangeEndDecoration: const BoxDecoration(
                      shape: BoxShape.circle, color: primaryColor),
                  rangeHighlightColor: primaryColor.withOpacity(0.3)),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          )
        ],
      ),
    );
  }
}
