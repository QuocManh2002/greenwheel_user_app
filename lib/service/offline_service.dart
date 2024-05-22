import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:hive/hive.dart';

import '../view_models/location_viewmodels/emergency_contact.dart';
import '../view_models/plan_viewmodels/surcharge.dart';

class OfflineService {
  Future<void> savePlanToHive(PlanDetail plan) async {
    final LocationService locationService = LocationService();
    final location = await locationService.getLocationById(plan.locationId!);
    final myPlans = Hive.box('myPlans');
    if (location != null) {
      await myPlans.put(plan.id, {
        'id': plan.id,
        'utcDepartAt': plan.utcDepartAt,
        'utcEndAt': plan.utcEndAt,
        'utcStartAt': plan.utcStartAt,
        'maxMemberCount': plan.maxMemberCount,
        'schedule': plan.schedule,
        'leaderId': plan.leaderId,
        'imageBase64': await Utils()
            .getImageBase64Encoded('$baseBucketImage${plan.imageUrls![0]}'),
        'name': plan.name,
        'orders': plan.orders,
        'members': convertMemberList(plan.members!, plan.leaderId!),
        'startLocationLat': plan.startLocationLat,
        'startLocationLng': plan.startLocationLng,
        'departureAddress': plan.departureAddress,
        'savedContacts': plan.savedContacts!
            .map((e) => EmergencyContactViewModel().toJsonOffline(e))
            .toList(),
        'surcharges':
            plan.surcharges!.map((e) => e.toJsonWithoutImage()).toList(),
        'note': plan.note,
        'travelDuration': plan.travelDuration,
        'numOfExpPeriod': plan.numOfExpPeriod,
        'locationName': plan.locationName,
        'leaderName': plan.leaderName,
        'routeData': json.encode(await getRouteInfo(
            PointLatLng(plan.startLocationLat!, plan.startLocationLng!),
            PointLatLng(location.latitude, location.longitude))),
        'locationLatLng': [plan.locationLatLng!.latitude, plan.locationLatLng!.longitude]
      });
    }
  }

  List<dynamic>? getOfflinePlans() {
    final myPlans = Hive.box('myPlans');
    final data = myPlans.keys.map((e) {
      final plan = myPlans.get(e);
      return {
        'plan': PlanDetail(
          id: plan['id'],
          name: plan['name'],
          imageUrls: [plan['imageBase64']],
          utcDepartAt: plan['utcDepartAt'],
          utcEndAt: plan['utcEndAt'],
          maxMemberCount: plan['maxMemberCount'],
          members: convertToMemberList(plan['members']),
          schedule: plan['schedule'],
          // orders: plan['orders']
          startLocationLat: plan['startLocationLat'],
          startLocationLng: plan['startLocationLng'],
          departureAddress: plan['departureAddress'],
          savedContacts: List<EmergencyContactViewModel>.from(
                  plan['savedContacts']
                      .map((e) => EmergencyContactViewModel.fromJsonOffline(e)))
              .toList(),
          surcharges: List<SurchargeViewModel>.from(plan['surcharges']
              .map((e) => SurchargeViewModel.fromJsonLocal(e))).toList(),
          note: plan['note'],
          travelDuration: plan['travelDuration'],
          leaderId: plan['leaderId'],
          numOfExpPeriod: plan['numOfExpPeriod'],
          utcStartAt: plan['utcStartAt'],
          locationName: plan['locationName'],
          leaderName: plan['leaderName'],
          locationLatLng: PointLatLng(plan['locationLatLng'][0], plan['locationLatLng'][1])
        ),
        'routeData': plan['routeData']
      };
    }).toList();

    return data;
  }

  List<dynamic> convertMemberList(
      List<PlanMemberViewModel> memberList, int leaderId) {
    return memberList
        .map((e) => {
              'memberId': e.memberId,
              'accountId': e.accountId,
              'name': e.name,
              'phone': e.phone,
              'isMale': e.isMale,
              'weight': e.weight,
              'status': e.status,
              'avatarPath': e.imagePath,
              'companions': e.companions
            })
        .toList();
  }

  List<PlanMemberViewModel> convertToMemberList(List<dynamic> memberList) {
    return memberList
        .map((e) => PlanMemberViewModel(
            memberId: e['memberId'],
            name: e['name'],
            phone: e['phone'],
            isMale: e['isMale'],
            weight: e['weight'],
            accountId: e['accountId'],
            status: e['status'],
            companions: e['companions'],
            imagePath: e['avatarPath']))
        .toList();
  }
}
