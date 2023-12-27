import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:hive/hive.dart';

class OfflineService {
  
  Future<void> savePlanToHive(PlanDetail planDetail) async {
    final _myPlans = Hive.box('myPlans');
    await _myPlans.add({
      'id': planDetail.id,
      'startDate': planDetail.startDate,
      'endDate': planDetail.endDate,
      'memberLimit': planDetail.memberLimit,
      'schedule': planDetail.schedule,
      'imageUrl': planDetail.imageUrls,
      'name': planDetail.name,
    });
    print('The number of plan: ${_myPlans.length}');
    // _myPlans.close();
  }

  Future<List<Map<String, dynamic>>> getOfflinePlans() async {
    final _myPlans = Hive.box('myPlans');
    final data = _myPlans.keys.map((e) {
      final plan = _myPlans.get(e);
      return {
        'key':e,
        'id': plan['id'],
        'startDate': plan['startDate'],
        'endDate': plan['endDate'],
        'memberLimit': plan['memberLimit'],
        'schedule': plan['schedule'],
        'imageUrl': plan['imageUrl'],
        'name': plan['name'],
      };
    }).toList();

    final rs = data.reversed.toList();
    return rs;
  }
}
