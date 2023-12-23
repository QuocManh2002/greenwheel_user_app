import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class NewScheduleItemScreen extends StatelessWidget {
  const NewScheduleItemScreen(
      {super.key,
      required this.callback,
      required this.startDate,
      required this.endDate,
      this.item});
  final void Function(PlanScheduleItem item, bool isCreate, PlanScheduleItem? oldItem) callback;
  final DateTime startDate;
  final DateTime endDate;
  final PlanScheduleItem? item;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _titleController = TextEditingController();
    TextEditingController _dateController = TextEditingController();
    TextEditingController _timeController = TextEditingController();
    TimeOfDay _selectTime = TimeOfDay.now();
    DateTime _selectedDate = DateTime.now();

    if (item != null) {
      _selectTime = item!.time;
      _selectedDate = item!.date;
      _titleController.text = item!.title;
      _dateController.text = DateFormat.yMMMMEEEEd('vi_VN').format(item!.date);
      _timeController.text = item!.time.format(context).toString();
    }

    _appBar(BuildContext ctx) {
      return AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (item == null) {
                    callback(
                        PlanScheduleItem(
                            time: _selectTime,
                            title: _titleController.text,
                            date: _selectedDate),
                        true, null);
                  }else{
                    callback(PlanScheduleItem(
                            time: _selectTime,
                            title: _titleController.text,
                            date: _selectedDate,
                            id: item!.id), false, item);
                  }

                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(
                Icons.done,
                color: Colors.white,
              ),
              label: const Text('Lưu'))
        ],
      );
    }

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm hoạt động',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultTextFormField(
                          controller: _titleController,
                          inputType: TextInputType.text,
                          text: 'Hoạt động mới',
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Ngày của hoạt động không được để trống";
                            }
                          },
                          hinttext: 'Câu cá, tắm suối...'),
                      SizedBox(
                        height: 2.h,
                      ),
                      defaultTextFormField(
                          readonly: true,
                          controller: _dateController,
                          inputType: TextInputType.datetime,
                          text: 'Ngày',
                          onTap: () async {
                            DateTime? newDay = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2024),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData().copyWith(
                                        colorScheme: const ColorScheme.light(
                                            primary: primaryColor,
                                            onPrimary: Colors.white)),
                                    child: DatePickerDialog(
                                      initialDate:
                                          item != null ? item!.date : startDate,
                                      firstDate: startDate,
                                      lastDate: endDate,
                                    ),
                                  );
                                });
                            if (newDay != null) {
                              _selectedDate = newDay;
                              _dateController.text =
                                  DateFormat.yMMMMEEEEd('vi_VN').format(newDay);
                            }
                          },
                          prefixIcon: const Icon(Icons.calendar_month),
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Ngày của hoạt động không được để trống";
                            }
                          }),
                      SizedBox(
                        height: 2.h,
                      ),
                      defaultTextFormField(
                          readonly: true,
                          controller: _timeController,
                          inputType: TextInputType.datetime,
                          text: 'Giờ',
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData().copyWith(
                                      colorScheme: const ColorScheme.light(
                                          primary: primaryColor,
                                          onPrimary: Colors.white)),
                                  child: TimePickerDialog(
                                    initialTime: item != null
                                        ? item!.time
                                        : TimeOfDay.now(),
                                  ),
                                );
                              },
                            ).then((value) {
                              _selectTime = value!;
                              _timeController.text =
                                  value.format(context).toString();
                              print(_timeController.text);
                            });
                          },
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Ngày của hoạt động không được để trống";
                            }
                          },
                          prefixIcon: const Icon(Icons.watch_later_outlined)),
                    ],
                  )),
            )
          ],
        ),
      ),
    ));
  }
}
