import 'dart:convert';

import 'package:greenwheel_user_app/view_models/order.dart';

class PlanItem {
  String title;
  DateTime? date;
  List<String> details;
  PlanItem({required this.title, required this.details, this.date});
}

String PlanItemToJson(PlanItem data) =>
    json.encode(List<String>.from(data.details.map((x) => x)));

String PlanItemsToJson(List<PlanItem> data) => json.encode(
      List<dynamic>.from(
          data.map((x) => List<PlanItem>.from(x.details.map((x) => x)))),
    );

List<PlanItem> generateDefaultItems (List<dynamic> plans, DateTime startDate, int duration){
  List<PlanItem> items = [];
  DateTime date = startDate;
  List<PlanItem> rs = [];
  for (int index = 0; index < plans.length; index++) {
    List<String> details = [];
    if(index != 0) date = date.add(const Duration(days: 1));

    for (final detail in plans[index]) {
      details.add(detail.toString());
    }
    items.add(PlanItem(title: "Ngày ${index + 1} (${date.day}/${date.month}/${date.year})", details: details, date: date));
  }

  if(duration <= plans.length){
    for(int index = 0 ; index < duration; index++){
      rs.add(items[index]);
    }
  }else{
    for(int index = 0 ; index < duration; index++){
      if(index < plans.length)
      {
        rs.add(items[index]);
      }
      else{
        DateTime date = startDate.add(Duration(days: index));
        rs.add(PlanItem(title: "Ngày ${index + 1} (${date.day}/${date.month}/${date.year})", details: [], date: date));
      }
    }
  }



  return rs;
}

List<PlanItem> generateItems(List<dynamic> plans, DateTime startDate, List<OrderViewModel> orders) {
  List<PlanItem> items = [];
  DateTime date = startDate;
  for (int index = 0; index < plans.length; index++) {
    List<String> details = [];
    if(index != 0) date = date.add(const Duration(days: 1));
    for (final detail in plans[index]) {
      details.add(detail.toString());
    }
    for(final order in orders){
      for(final servingDate in order.servingDates){
        if(DateTime.parse(servingDate).toLocal() == date.toLocal().subtract(const Duration(hours: 7))){
          if(order.details![0].type == "RESTAURANT"){
            details.add("Dùng bữa tại ${order.details![0].supplierName}");
          }else{
            details.add("Nghỉ ngơi tại ${order.details![0].supplierName}");
          }
        }
      }
    }
    items.add(PlanItem(title: "Ngày ${index + 1} (${date.day}/${date.month}/${date.year})", details: details, date: date));
  }
  return items;
}
