import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:hive/hive.dart';

class OfflineService {
  final _myPlans = Hive.box('myPlans');
  Future<void> savePlanToHive(PlanDetail planDetail) async {

    await _myPlans.add({
      'id':planDetail.id,
      'startDate' :planDetail.startDate,
      'endDate': planDetail.endDate,
      'memberLimit':planDetail.memberLimit,
    });
    print('The number of plan: ${_myPlans.length}');
  }
}
