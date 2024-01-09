import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';

class PlanSchedule {
  final DateTime date;
  List<PlanScheduleItem> items;

  PlanSchedule({required this.date, required this.items});

  // List toJson(PlanSchedule model) => [items.map((e) => e.toJson(e))];
}
