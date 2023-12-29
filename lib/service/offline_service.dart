import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:hive/hive.dart';

class OfflineService {

  Future<void> savePlanToHive(PlanOfflineViewModel plan) async {
    final _myPlans = Hive.box('myPlans');
    await _myPlans.add({
      'id': plan.id,
      'startDate': plan.startDate,
      'endDate': plan.endDate,
      'memberLimit': plan.memberLimit,
      'schedule': plan.schedule,
      'imageBase64': plan.imageBase64,
      'name': plan.name,
      'orders': plan.orders,
      'memberList': convertMemberList(plan.memberList!)
    });
    print('The number of plan: ${_myPlans.length}');
  }

  List<PlanOfflineViewModel>? getOfflinePlans() {
    final _myPlans = Hive.box('myPlans');
    final data = _myPlans.keys.map((e) {
      final plan = _myPlans.get(e);
      return PlanOfflineViewModel(
        id: plan['id'],
        name: plan['name'],
        imageBase64: plan['imageBase64'],
        startDate: plan['startDate'],
        endDate: plan['endDate'],
        memberLimit: plan['memberLimit'],
        memberList: convertToMemberList(plan['memberList']),
        schedule: plan['schedule'],
        // orders: plan['orders']
      );
    }).toList();

    return data;
  }

  List<dynamic> convertMemberList(List<PlanOfflineMember> memberList) {
    return memberList
        .map((e) => {
              'id': e.id,
              'name': e.name,
              'phone': e.phone,
              'isLeading': e.isLeading
            })
        .toList();
  }

  List<PlanOfflineMember> convertToMemberList(List<dynamic> memberList) {
    return memberList
        .map((e) => PlanOfflineMember(
            id: e['id'],
            name: e['name'],
            phone: e['phone'],
            isLeading: e['isLeading']))
        .toList();
  }
}
