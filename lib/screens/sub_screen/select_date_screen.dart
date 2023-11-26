import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/draft.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:sizer2/sizer2.dart';

class SelectDateScreen extends StatefulWidget {
  const SelectDateScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  PlanService _planService = PlanService();
  bool isLoading = true;
  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickDateRange();
  }

  int _selectedQuantity = 1;

  

  Future pickDateRange() async {
    DateTimeRange? newSelectedDate = await showDateRangePicker(
        context: context,
        initialDateRange: selectedDates,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (newSelectedDate == null) {
      return;
    }
    setState(() {
      selectedDates = newSelectedDate;
    });
  }

  onChangeQuantity(String type) {
    if (type == "add") {
      setState(() {
        _selectedQuantity += 1;
      });
    } else {
      setState(() {
        _selectedQuantity -= 1;
      });
    }
  }
  
  _createDraftPlan() async{
    LocationService locationService = LocationService();
    LocationViewModel? location = await locationService.GetLocationById(widget.location.id);
    // List<List<String>> schedule = json.decode(location!.templatePlan);
    List<List<String>> schedule = [];
    for(final detail in json.decode(location!.templatePlan)){
      List<String> items = [];
      for(final item in detail){
        items.add(json.encode(item));
      }
      schedule.add(items);
    }
    PlanDraft draft = PlanDraft(startDate: selectedDates.start, endDate: selectedDates.end, locationId: widget.location.id, memberLimit: _selectedQuantity, schedule: schedule);

    var rs = await _planService.createPlanDraft(draft);
    if(rs){
      Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CreatePlanScreen(
                            location: widget.location,
                            endDate: selectedDates.end,
                            startDate: selectedDates.start,
                            numberOfMember: _selectedQuantity,
                            duration: selectedDates.duration.inDays + 1,
                          )));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final start = selectedDates.start;
    final end = selectedDates.end;

    

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Thông tin ban đầu",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          const SizedBox(
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              "Thời gian chuyến đi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: pickDateRange,
                  style: elevatedButtonStyle,
                  child: Text('${start.day}/${start.month}/${start.year}'),
                )),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: pickDateRange,
                  child: Text('${end.day}/${end.month}/${end.year}'),
                ))
              ],
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              "Số lượng thành viên của chuyến đi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  color: primaryColor,
                  iconSize: 30,
                  onPressed: () {
                    onChangeQuantity("subtract");
                  },
                  icon: const Icon(Icons.remove)),
              Container(
                alignment: Alignment.center,
                height: 5.h,
                width: 10.h,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _selectedQuantity.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                  color: primaryColor,
                  iconSize: 30,
                  onPressed: () {
                    onChangeQuantity("add");
                  },
                  icon: const Icon(Icons.add)),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _createDraftPlan,
                child: const Text(
                  "Chọn",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    ));
  }
}
