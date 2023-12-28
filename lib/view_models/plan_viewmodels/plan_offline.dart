import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';

class PlanOfflineViewModel {
  int id;
  String name;
  String imageBase64;
  DateTime startDate;
  DateTime endDate;
  int memberLimit;
  List<OrderViewModel>? orders;
  List<dynamic>? schedule;
  List<PlanOfflineMember>? memberList;

  PlanOfflineViewModel(
      {required this.id,
      required this.name,
      required this.imageBase64,
      required this.startDate,
      required this.endDate,
      required this.memberLimit,
      this.schedule,
      required this.memberList,
      this.orders});
}
