import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class NewScheduleItemScreen extends StatefulWidget {
  const NewScheduleItemScreen(
      {super.key,
      required this.callback,
      required this.startDate,
      required this.selectedIndex,
      this.item});
  final void Function(
      PlanScheduleItem item, bool isCreate, PlanScheduleItem? oldItem) callback;
  final DateTime startDate;
  final PlanScheduleItem? item;
  final int selectedIndex;

  @override
  State<NewScheduleItemScreen> createState() => _NewScheduleItemScreenState();
}

class _NewScheduleItemScreenState extends State<NewScheduleItemScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TimeOfDay _selectTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  String? _selectedType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    if (widget.item != null) {
      _selectTime = widget.item!.time;
      _selectedDate = widget.item!.date!;
      _titleController.text = widget.item!.title;
      _selectedType = widget.item!.type;
      setState(() {
        _dateController.text =
            DateFormat.yMMMMEEEEd('vi_VN').format(widget.item!.date!);
        // _timeController.text = '${widget.item!.time.hour}:${widget.item!.time.minute}';

        _timeController.text = DateFormat.Hm().format(DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectTime.hour,
            _selectTime.minute));
      });
    } else {
      setState(() {
        _dateController.text = DateFormat.yMMMMEEEEd('vi_VN')
            .format(widget.startDate.add(Duration(days: widget.selectedIndex)));
        _selectedDate =
            widget.startDate.add(Duration(days: widget.selectedIndex));
      });
    }
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
                if (widget.item == null) {
                  if (_selectedType == null) {
                    await AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      body: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Hãy chọn dạng hoạt động',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      btnOkColor: Colors.orange,
                      btnOkText: 'Ok',
                      btnOkOnPress: () {},
                    ).show();
                  } else {
                    widget.callback(
                        PlanScheduleItem(
                            time: _selectTime,
                            title: _titleController.text,
                            date: _selectedDate,
                            type: _selectedType),
                        true,
                        null);
                    Navigator.of(context).pop();
                  }
                } else {
                  widget.callback(
                      PlanScheduleItem(
                          type: _selectedType,
                          time: _selectTime,
                          title: _titleController.text,
                          date: _selectedDate,
                          id: widget.item!.id),
                      false,
                      widget.item);
                  Navigator.of(context).pop();
                }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item != null ? 'Chỉnh sửa hoạt động' : 'Thêm hoạt động',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              padding: const EdgeInsets.only(left: 12, right: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(14))),
              child: DropdownButton<String>(
                hint: const Text(
                  'Dạng hoạt động',
                  style: TextStyle(fontSize: 18),
                ),
                iconSize: 36,
                underline: const SizedBox(),
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(color: Colors.black, fontSize: 18),
                value: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    print(1);
                  });
                },
                items: schedule_item_types_vn
                    .map(
                      (e) => DropdownMenuItem(child: Text(e), value: e),
                    )
                    .toList(),
              ),
            ),
            Container(
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      defaultTextFormField(
                          controller: _titleController,
                          inputType: TextInputType.text,
                          text: widget.item != null
                              ? 'Mô tả hoạt động'
                              : 'Mô tả hoạt động mới',
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Mô tả của hoạt động không được để trống";
                            }
                          },
                          hinttext: 'Câu cá, tắm suối...'),
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
                                    initialTime: widget.item != null
                                        ? widget.item!.time
                                        : TimeOfDay.now(),
                                  ),
                                );
                              },
                            ).then((value) {
                              var startTimeText = sharedPreferences.getString('plan_start_time');
                              print(_selectedDate.difference(widget.startDate).inDays == 0);
                              if(_selectedDate.difference(widget.startDate).inDays == 0){
                                
                              }
                              _selectTime = value!;
                              _timeController.text =
                                  value.format(context).toString();
                              // print(_timeController.text);
                            });
                          },
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Ngày của hoạt động không được để trống";
                            }
                          },
                          prefixIcon: const Icon(Icons.watch_later_outlined)),
                      SizedBox(
                        height: 2.h,
                      ),
                      // defaultTextFormField(
                      //   readonly: true,
                      //   controller: _dateController,
                      //   inputType: TextInputType.datetime,
                      //   text: 'Ngày',
                      //   prefixIcon: const Icon(Icons.calendar_month),
                      // ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 18),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month),
                            prefixIconColor: primaryColor,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    ));
  }
}
