
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';

class PlanOfflineViewModel {
  PlanDetail plan;
  String routeData;
  double totalOrder;

  PlanOfflineViewModel(
      {required this.plan,
      required this.routeData,
      required this.totalOrder});
}
