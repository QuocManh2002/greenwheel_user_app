import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectStartDateScreen extends StatefulWidget {
  const SelectStartDateScreen({super.key});

  @override
  State<SelectStartDateScreen> createState() => _SelectStartDateScreenState();
}

class _SelectStartDateScreenState extends State<SelectStartDateScreen> {

  TextEditingController _timeController = TextEditingController();
  TimeOfDay _selectTime = TimeOfDay.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  _onDaySelected(DateTime selectDay, DateTime focusDay){
    if(!isSameDay(_selectedDate, selectDay)){
      setState(() {
        _selectedDate = selectDay;
        _focusedDay = focusDay;
        _rangeStart = _selectedDate;
        _rangeEnd = _selectedDate!.add(Duration(days: 2));
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDate = _focusedDay;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 3.h,),
          const Text('Tổng thời gian chuyến đi', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold
          ),),
          SizedBox(height: 2.h,),
          const Text('(Bao gồm thời gian di chuyển từ địa điểm xuất phát)', 
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey
          ),
          ),
          SizedBox(height: 3.h,),
          const Text('3 ngày 3 đêm', 
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),),
          const Text('7:00 AM 11/4/2023 - 1:00 PM 13/04/2023',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),),
          SizedBox(height: 3.h,),
          TableCalendar(
                  locale: 'vi_VN',
                  focusedDay: _focusedDay, 
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  calendarFormat: _calendarFormat,
                  onDaySelected: _onDaySelected,
                  firstDay: DateTime(2023), 
                  lastDay: DateTime(2025),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarStyle: CalendarStyle(
                    selectedDecoration:const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle
                    ),
                    todayDecoration:const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent
                    ),
                    rangeEndDecoration:const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor
                    ),
                    rangeHighlightColor: primaryColor.withOpacity(0.5)
                  ),
                  onFormatChanged: (format) {
                    if(_calendarFormat != format){
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  )
        ],
      ),
    );
  }
}