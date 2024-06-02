import 'package:phuot_app/view_models/plan_viewmodels/plan_schedule_item.dart';

class PlanSchedule {
  final DateTime? date;
  List<PlanScheduleItem> items;

  PlanSchedule({ this.date, required this.items});
}
