class PlanItem{
  String title;
  List<String> details;
  PlanItem({required this.title, required this.details,});
}

List<PlanItem> planItems (int numberOfDays){
  return List.generate(numberOfDays, (index) => 
    PlanItem(title: "Ngày ${index + 1}", details: ["Câu cá", "Tắm suối", "Leo núi"])
  );
}