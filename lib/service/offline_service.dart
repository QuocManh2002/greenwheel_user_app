import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/plan_statuses.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../view_models/location_viewmodels/emergency_contact.dart';
import '../view_models/plan_viewmodels/surcharge.dart';

class OfflineService {
  Future<void> savePlanToHive() async {
    await Hive.initFlutter();
    final myPlans = await Hive.openBox('myPlans');
    final LocationService locationService = LocationService();
    final PlanService planService = PlanService();
    final OrderService orderService = OrderService();
    List<PlanCardViewModel>? planCards = await planService.getPlanCards(false);
    for (final planCard in planCards!) {
      if (planCard.status == planStatuses[2].engName &&
          myPlans.get(planCard.id) == null) {
        PlanDetail? plan = await planService.getPlanById(planCard.id, 'JOIN');
        final location =
            await locationService.getLocationById(plan!.locationId!);
        final planOrders =
            await orderService.getOrderByPlan(plan.id!, 'JOIN');
        if (location != null) {
          await myPlans.put(
              plan.id, convertToOfflinePlan(plan, location, planOrders));
        }
      } else if (planCard.utcEndAt!.toLocal().isAfter(DateTime.now())) {
        myPlans.delete(planCard.id);
      }
    }
  }

  List<PlanOfflineViewModel>? getOfflinePlans() {
    final myPlans = Hive.box('myPlans');
    final data = myPlans.keys.map((e) {
      final plan = myPlans.get(e);
      List<OrderViewModel> orders = [];
      double totalOrders = 0;
      for (final order in plan['orders']) {
        totalOrders += order['total'];
        orders.add(OrderViewModel(
            createdAt: DateTime.parse(order['createdAt']),
            details: order['details']
                .map((detail) => OrderDetailViewModel(
                    productName: detail['productName'],
                    price: detail['price'],
                    quantity: detail['quantity'],
                    productId: detail['productId']))
                .toList(),
            uuid: order['orderUUID'],
            note: order['note'],
            period: order['period'],
            serveDates: order['serveDates'],
            total: order['total'],
            type: order['type'],
            supplier: SupplierViewModel(
                id: order['providerId'],
                type: order['providerType'],
                name: order['providerName'],
                phone: order['providerPhone'],
                thumbnailUrl: order['providerImageUrl'],
                address: order['providerAddress'])));
      }
      return PlanOfflineViewModel(
          plan: PlanDetail(
              id: plan['id'],
              name: plan['name'],
              imageUrls: [plan['imageBase64']],
              utcDepartAt: plan['utcDepartAt'],
              utcEndAt: plan['utcEndAt'],
              maxMemberCount: plan['maxMemberCount'],
              memberCount: plan['memberCount'],
              members: convertToMemberList(plan['members']),
              actualGcoinBudget: plan['actualGcoinBudget'],
              schedule: plan['schedule'],
              orders: orders,
              startLocationLat: plan['startLocationLat'],
              startLocationLng: plan['startLocationLng'],
              departureAddress: plan['departureAddress'],
              savedContacts: List<EmergencyContactViewModel>.from(
                      plan['savedContacts'].map(
                          (e) => EmergencyContactViewModel.fromJsonOffline(e)))
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
              gcoinBudgetPerCapita: plan['gcoinBudgetPerCapita'],
              locationLatLng: PointLatLng(
                  plan['locationLatLng'][0], plan['locationLatLng'][1])),
          routeData: plan['routeData'],
          totalOrder: totalOrders);
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

  convertToOfflinePlan(
      PlanDetail plan, LocationViewModel location, dynamic planOrders) async {
    OrderService orderService = OrderService();
    plan.orders = planOrders!['orders'] ?? [];
    var orders = [];
    for (final schedule in plan.schedule!) {
      for (final item in schedule) {
        if (item['orderUUID'] != null) {
          final order = plan.orders ??
              [].firstWhereOrNull((order) => order.uuid == item['orderUUID']);
          if (order == null) {
            item['orderUUID'] = null;
          }
        }
      }
    }
    for (final order in plan.orders!) {
      final orderDetailGroupList =
          order.details!.groupListsBy((e) => e.productId);
      final orderDetailList =
          orderDetailGroupList.entries.map((e) => e.value.first).toList();
      orders.add(orderService.convertToTempOrder(
          order.supplier!,
          order.note!,
          order.type!,
          orderDetailList
              .map((item) => {
                    'productId': item.productId,
                    'productName': item.productName,
                    'quantity': item.quantity,
                    'partySize': item.partySize,
                    'price': item.price
                  })
              .toList(),
          order.period!,
          order.serveDates!.map((date) => date.toString()).toList(),
          order.serveDates!
              .map((date) => DateTime.parse(date.toString())
                  .difference(DateTime(
                      plan.utcStartAt!.toLocal().year,
                      plan.utcStartAt!.toLocal().month,
                      plan.utcStartAt!.toLocal().day,
                      0,
                      0,
                      0))
                  .inDays)
              .toList(),
          order.uuid,
          order.total!));
    }

    return {
      'id': plan.id,
      'utcDepartAt': plan.utcDepartAt,
      'utcEndAt': plan.utcEndAt,
      'utcStartAt': plan.utcStartAt,
      'maxMemberCount': plan.maxMemberCount,
      'memberCount': plan.memberCount,
      'schedule': plan.schedule,
      'leaderId': plan.leaderId,
      'imageBase64': await Utils()
          .getImageBase64Encoded('$baseBucketImage${plan.imageUrls![0]}'),
      'name': plan.name,
      'orders': orders,
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
      'locationLatLng': [
        plan.locationLatLng!.latitude,
        plan.locationLatLng!.longitude
      ],
      'gcoinBudgetPerCapita': plan.gcoinBudgetPerCapita,
      'actualGcoinBudget': plan.actualGcoinBudget
    };
  }

  Future<void> setUpDataForTest() async {
    try {
      final PlanService planService = PlanService();
      final LocationService locationService = LocationService();
      final OrderService orderService = OrderService();
      await Hive.initFlutter();
      final myPlans = await Hive.openBox('myPlans');
      final ids = [3263, 3264, 3265];
      for (final id in ids) {
        PlanDetail? plan = await planService.getPlanById(id, 'PUBLISH');
        final location =
            await locationService.getLocationById(plan!.locationId!);
        final planOrders =
            await orderService.getOrderByPlan(plan.id!, 'PUBLISH');
        if (location != null) {
          await myPlans.put(
              plan.id, convertToOfflinePlan(plan, location, planOrders));
        }
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
