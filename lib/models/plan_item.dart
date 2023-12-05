import 'dart:convert';

class PlanItem{
  String title;
  List<String> details;
  PlanItem({required this.title, required this.details,});

}

String PlanItemToJson(PlanItem data) => json.encode(List<String>.from(data.details.map((x) => x)));

String PlanItemsToJson(List<PlanItem> data) => json.encode(List<dynamic>.from(data.map((x) => List<PlanItem>.from(x.details.map((x) => x)))),);


List<PlanItem> planItems (int numberOfDays){
  return List.generate(numberOfDays, (index) => 
    PlanItem(title: "Ngày ${index + 1}", details: ["Câu cá", "Tắm suối", "Leo núi"])
  );
}

List<PlanItem> generateItems(List<dynamic> plans) {
      // var rs = json.decode(itemText);
      List<PlanItem> items = [];
      for (int index = 0; index < plans.length; index++) {
        List<String> details = [];
        for (final detail in plans[index]) {
          details.add(detail.toString());
        }
        items.add(PlanItem(title: "Ngày ${index + 1}", details: details));
      }
      return items;
    }



   


