import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/core/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/suggest_plan.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sizer2/sizer2.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  final Location _locationController = Location();

  Future<int> createNewPlan(
      PlanCreate model, BuildContext context, String surcharges) async {
    var schedule = json.decode(model.schedule!);
    final emerIds =
        json.decode(model.savedContacts!).map((e) => e['id']).toList();
    log("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departAddress}"
    departAt:"${model.departAt!.year}-${model.departAt!.month}-${model.departAt!.day} ${model.departAt!.hour}:${model.departAt!.minute}:00.000+07:00"
    departure:[${model.departCoordinate!.longitude},${model.departCoordinate!.latitude}]
    destinationId:${model.locationId}
    maxMemberCount:${model.maxMemberCount}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:$emerIds
    schedule:$schedule
    surcharges:${surcharges}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}
""");
    try {
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departAddress}"
    departAt:"${model.departAt!.year}-${model.departAt!.month}-${model.departAt!.day} ${model.departAt!.hour}:${model.departAt!.minute}:00.000+07:00"
    departure:[${model.departCoordinate!.longitude},${model.departCoordinate!.latitude}]
    destinationId:${model.locationId}
    maxMemberCount:${model.maxMemberCount}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:$emerIds
    schedule:$schedule
    surcharges:${surcharges}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}
"""),
      ));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      } else {
        var rstext = result.data!;
        int planId = rstext['createPlan']['id'];
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int?> updatePlan(
      PlanCreate model, String surcharges, BuildContext context) async {
    try {
      log('''

mutation{
  updatePlan(dto: {
    planId:${sharedPreferences.getInt('planId')}
    departureAddress:"${model.departAddress}"
    departAt:"${model.departAt!.year}-${model.departAt!.month}-${model.departAt!.day} ${model.departAt!.hour}:${model.departAt!.minute}:00.000+07:00"
    departure:[${model.departCoordinate!.longitude},${model.departCoordinate!.latitude}]
    maxMemberCount:${model.maxMemberCount}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:${model.savedContactIds}
    schedule:${json.decode(model.schedule!)}
    surcharges:${json.decode(surcharges)}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}''');
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
  mutation{
  updatePlan(dto: {
    planId:${sharedPreferences.getInt('planId')}
    departureAddress:"${model.departAddress}"
    departAt:"${model.departAt!.year}-${model.departAt!.month}-${model.departAt!.day} ${model.departAt!.hour}:${model.departAt!.minute}:00.000+07:00"
    departure:[${model.departCoordinate!.longitude},${model.departCoordinate!.latitude}]
    maxMemberCount:${model.maxMemberCount}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:${model.savedContactIds}
    schedule:${json.decode(model.schedule!)}
    surcharges:${json.decode(surcharges)}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      } else {
        var rstext = result.data!;
        int planId = rstext['updatePlan']['id'];
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> clonePlan(
      PlanCreate model, BuildContext context, String surcharges) async {
    try {
      var schedule = json.decode(model.schedule!);
      final emerIds =
          json.decode(model.savedContacts!).map((e) => e['id']).toList();
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departAddress}"
    departAt:"${model.departAt!.year}-${model.departAt!.month}-${model.departAt!.day} ${model.departAt!.hour}:${model.departAt!.minute}:00.000+07:00"
    departure:[${model.departCoordinate!.longitude},${model.departCoordinate!.latitude}]
    destinationId:${model.locationId}
    maxMemberCount:${model.maxMemberCount}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:$emerIds
    schedule:$schedule
    surcharges:${surcharges}
    travelDuration:"${model.travelDuration}"
    sourceId:${sharedPreferences.getInt('planId')}
  }){
    id
  }
}
"""),
      ));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      } else {
        var rstext = result.data!;
        int planId = rstext['createPlan']['id'];
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map?> getOrderCreatePlan(int planId, String planType) async {
    try {
      String type = '';
      switch (planType) {
        case 'OWNED':
          type = 'ownedPlans';
          break;
        case 'JOIN':
          type = 'joinedPlans';
          break;
        case 'PUBLISH':
          type = 'publishedPlans';
      }
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  $type(where: { id: { eq: $planId } }) {
    nodes {
      actualGcoinBudget
      orders {
        id
        planId
        total
        serveDates
        note
        createdAt
        period
        type
        currentStatus
        provider {
          type
          id
          phone
          name
          imagePath
          address
        }
        details {
          id
          price
          quantity
          product {
            id
            name
            type
            price
          }
        }
      }
    }
  }
}
""")));

      if (result.hasException) {
        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data![type]['nodes'][0]['orders'];
      if (res == null) {
        return null;
      }
      List<OrderViewModel>? orders = [];
      for (final item in res) {
        OrderViewModel order = OrderViewModel.fromJson(item);
        if (order.currentStatus != 'CANCELLED') {
          List<OrderDetailViewModel>? details = [];
          for (final detail in item['details']) {
            details.add(OrderDetailViewModel.fromJson(detail));
            order.details = details;
          }
          orders.add(order);
        }
      }
      return {
        'orders': orders,
        'currentBudget': result.data![type]['nodes'][0]['actualGcoinBudget']
      };
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<PlanDetail?> GetPlanById(int planId, String type) async {
    try {
      String planType = '';
      switch (type) {
        case "JOIN":
          planType = 'joinedPlans';
          break;
        case "OWNED":
          planType = 'ownedPlans';
          break;
        case "INVITATION":
          planType = 'invitations';
          break;
        case "SCAN":
          planType = 'scannablePlans';
          break;
        case "PUBLISH":
          planType = 'publishedPlans';
          break;
      }
      QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
  $planType(where: { id: { eq: $planId } }) {
    nodes {
      name
      id
      startDate
      endDate
      departureAddress
      accountId
      account {
        name
      }
      joinMethod
      gcoinBudgetPerCapita
      actualGcoinBudget
      displayGcoinBudget
      travelDuration
      note
      memberCount
      maxMemberCount
      maxMemberWeight
      savedProviders {
        id
        provider{
          name
          phone
          address
          imagePath
          type
        }
      }
      status
      periodCount
      departure {
        coordinates
      }
      destination {
        id
        name
        imagePaths
      }
      members {
        status
        weight
        companions
        account {
          avatarPath
          id
          name
          phone
          isMale
        }
        id
      }
      surcharges {
        amount
        alreadyDivided
        id
        imagePath
        note
      }
      utcRegCloseAt
      utcDepartAt
      utcStartAt
      utcEndAt
      schedule
    }
  }
}
"""),
      ));

      if (result.hasException) {
        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data![planType]['nodes'];
      if (res == null || res.isEmpty) {
        return null;
      }
      List<PlanDetail> plan =
          res.map((plan) => PlanDetail.fromJson(plan)).toList();
      var rs = plan[0];
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>?> getPlanCards(
      bool isOwned, BuildContext context) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  ${isOwned ? 'ownedPlans' : 'joinedPlans'}(first: 50
  order: {
  id:DESC
}
  ){
    nodes{
      id
      name
      startDate
      endDate
      status
      destination{
        id
          description
          imagePaths
          name
          activities
          seasons
          topographic
          coordinate{coordinates}
          address
          province{
            id
            name
            imagePath
          }
      }
    }
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data![isOwned ? 'ownedPlans' : 'joinedPlans']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<PlanCardViewModel> plans =
          res.map((plan) => PlanCardViewModel.fromJson(plan)).toList();
      return plans;
    } catch (error) {
      throw Exception(error);
    }
  }

  List<List<String>> GetPlanDetailFormJson(List<dynamic> details) {
    List<List<String>> schedule = [];
    for (final detail in details) {
      List<String> items = [];
      for (final item in detail) {
        items.add(json.encode(item));
      }
      schedule.add(items);
    }
    return schedule;
  }

  List<PlanSchedule> GetPlanScheduleClone(List<PlanSchedule> schedules) {
    for (final schedule in schedules) {
      if (schedule.items.isNotEmpty) {
        for (int i = 0; i < schedule.items.length; i++) {
          schedule.items.removeWhere((element) => element.orderId != null);
        }
      }
    }
    return schedules;
  }

  List<PlanSchedule> ConvertPLanJsonToObject(
      int duration, DateTime startDate, String scheduleText) {
    List<PlanSchedule> list = [];
    List<dynamic> _scheduleList = json.decode(scheduleText);
    for (final sche in _scheduleList) {
      List<PlanScheduleItem> eventList = [];
      for (final event in sche) {
        eventList.add(PlanScheduleItem(
            tempOrder: event['tempOrder'],
            isStarred: event['isStarred'],
            activityTime: int.parse(
                json.decode(event['duration']).toString().split(':')[0]),
            description: json.decode(event['description']),
            shortDescription: json.decode(event['shortDescription']),
            type: schedule_item_types_vn[
                schedule_item_types.indexOf(event['type'])],
            date: startDate.add(Duration(days: _scheduleList.indexOf(sche)))));
      }
      list.add(PlanSchedule(
          date: startDate.add(Duration(days: _scheduleList.indexOf(sche))),
          items: eventList));
    }
    if (list.length < duration) {
      for (int i = list.length; i < duration; i++) {
        list.add(
            PlanSchedule(date: startDate.add(Duration(days: i)), items: []));
      }
    }
    return list;
  }

  List<PlanSchedule> GetPlanScheduleFromJsonNew(
      List<dynamic> schedules, DateTime startDate, int duration) {
    List<PlanSchedule> schedule = [];
    for (int i = 0; i < duration; i++) {
      List<PlanScheduleItem> item = [];
      final date = startDate.add(Duration(days: i));
      if (i < schedules.length) {
        for (final planItem in schedules[i]) {
          item.add(PlanScheduleItem(
              tempOrder: planItem['tempOrder'],
              isStarred: planItem['isStarred'],
              activityTime: DateFormat.Hms()
                  .parse(planItem['duration'].toString().substring(0, 1) == '\"'
                      ? json.decode(planItem['duration'])
                      : planItem['duration'])
                  .hour,
              shortDescription:
                  planItem['shortDescription'].toString().substring(0, 1) ==
                          '\"'
                      ? json.decode(planItem['shortDescription'])
                      : planItem['shortDescription'],
              type: schedule_item_types_vn[
                  schedule_item_types.indexOf(planItem['type'].toString())],
              description:
                  planItem['description'].toString().substring(0, 1) == '\"'
                      ? json.decode(planItem['description'])
                      : planItem['description'],
              date: date));
        }
      }
      schedule.add(PlanSchedule(date: date, items: item));
    }
    return schedule;
  }

  List<dynamic> convertPlanScheduleToJson(List<PlanSchedule> list) {
    List<dynamic> rs = [];
    for (final schedule in list) {
      var items = [];
      for (final item in schedule.items) {
        final type = schedule_item_types_vn
            .firstWhere((element) => element == item.type);
        dynamic details;
        if (item.tempOrder != null) {
          if (item.tempOrder['details'] != null) {
            details = item.tempOrder['details'].map((detail) {
              return {
                'key': detail['productId'],
                'value': detail['quantity'],
              };
            }).toList();
          } else {
            if (item.tempOrder['cart'].runtimeType == List) {
              details = item.tempOrder['cart']
                  .map((e) => {'key': e['key'], 'value': e['value']})
                  .toList();
            } else {
              details = item.tempOrder['cart'].entries
                  .map((e) => {'key': e.key, 'value': e.value})
                  .toList();
            }
          }
        }
        items.add({
          'tempOrder': item.tempOrder != null
              ? {
                  'cart': details,
                  'note': item.tempOrder['note'] != null
                      ? json.encode(item.tempOrder['note'])
                      : null,
                  'period': item.tempOrder['period'],
                  'providerId': item.tempOrder['providerId'],
                  'total': item.tempOrder['total']
                }
              : null,
          'isStarred': item.isStarred,
          'duration': json.encode("${item.activityTime}:00:00"),
          'description': json.encode(item.description),
          'shortDescription': json.encode(item.shortDescription),
          'type': schedule_item_types[schedule_item_types_vn.indexOf(type)]
        });
      }
      rs.add(items);
    }
    return rs;
  }

  Future<int?> joinPlan(
      int planId, List<String> names, BuildContext context) async {
    final listName = names.map((e) => json.encode(e)).toList();
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  joinPlan(dto: {
    companions:${listName.isEmpty ? null : listName}
    planId: $planId
  }){
    id
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      int? res = result.data!['joinPlan']['id'];
      if (res == null || res == 0) {
        return null;
      }
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanMemberViewModel>> getPlanMember(
      int planId, String type, BuildContext context) async {
    try {
      String planType = '';
      switch (type) {
        case "JOIN":
          planType = 'joinedPlans';
          break;
        case "OWNED":
          planType = 'ownedPlans';
          break;
        case "INVITATION":
          planType = 'invitations';
          break;
        case "SCAN":
          planType = 'scannablePlans';
          break;
        case "PUBLISH":
          planType = 'publishedPlans';
          break;
      }

      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  $planType(where: { id: { eq: $planId } }) {
    nodes {
      members {
        status
        weight
        companions
        account {
          name
          phone
          id
          isMale
          avatarPath
        }
        id
      }
    }
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data![planType]['nodes'][0]['members'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<PlanMemberViewModel> listResult =
          res.map((e) => PlanMemberViewModel.fromJson(e)).toList();
      return listResult;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> updateJoinMethod(
      int planId, String method, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  updateJoinMethod(dto: {
    joinMethod:$method,
    planId:$planId
  }){
    id
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      int? res = result.data!['updateJoinMethod']['id'];
      if (res == null || res == 0) {
        return false;
      }
      return true;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> inviteToPlan(
      int planId, int travelerId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  inviteToPlan(dto: {
    planId:$planId
    accountId:$travelerId
  }){
    id
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      } else {
        var rstext = result.data!;
        int rs = rstext['inviteToPlan']['id'];
        return rs;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  generateEmptySchedule(DateTime startDate, DateTime endDate) {
    int duration = endDate.difference(startDate).inDays;
    final arrivedTime = Utils().getArrivedTimeFromLocal();
    if (arrivedTime.hour >= 16 && arrivedTime.hour < 20) {
      duration++;
    }
    List<PlanSchedule> result = [];
    for (int i = 0; i < duration; i++) {
      result
          .add(PlanSchedule(date: startDate.add(Duration(days: i)), items: []));
    }
    return result;
  }

  Future<List<SuggestPlanViewModel>> getSuggestPlanByLocation(
      int locationId, BuildContext context) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  publishedPlans(where: {
    destinationId:{
      eq:$locationId
    }
  }){
    edges{
      node {
        id
        name
        startDate
        endDate
        account {
          name
        }
        utcDepartAt
      }
    }
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data!['publishedPlans']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<SuggestPlanViewModel> plans = res
          .map((plan) => SuggestPlanViewModel.fromJson(plan['node']))
          .toList();
      return plans;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String> publicizePlan(int planId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  publicizePlan(planId: $planId){
    id
    status
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      String? res = result.data!['publicizePlan']['status'];
      return res!;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> confirmMember(int planId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  confirmMembers(planId: $planId){
    id
    status
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      int? res = result.data!['confirmMembers']['id'];
      return res!;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> removeMember(
      int memberId, bool isBlock, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation{
  removeMember(dto: {
    planMemberId:$memberId
    alsoBlock:$isBlock
  }){
    id
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      int? res = result.data!['removeMember']['id'];
      if (res == null) {
        return 0;
      }
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> cancelPlan(int planId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation{
  cancelPlan(planId: $planId){
    id
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      int? res = result.data!['cancelPlan']['id'];
      if (res == null) {
        return 0;
      }
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> updateSurcharge(
      String imagePath, int surchargeId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation{
  updateSurcharge(dto: {
    imageUrl:"$baseBucketImage$imagePath"
    surchargeId:$surchargeId
  }){
    imagePath
  }
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      String? _imagePath = result.data!['updateSurcharge']['imagePath'];
      if (_imagePath == null) {
        return null;
      }
      return _imagePath;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>?> getPlanSchedule(int planId, String type) async {
    try {
      String planType = '';
      switch (type) {
        case "JOIN":
          planType = 'joinedPlans';
          break;
        case "OWNED":
          planType = 'ownedPlans';
          break;
        case "INVITATION":
          planType = 'invitations';
          break;
        case "SCAN":
          planType = 'scannablePlans';
          break;
        case 'PUBLISH':
          planType = 'publishedPlans';
          break;
      }

      QueryResult result = await client.query(QueryOptions(document: gql("""
{
  $planType(where:{
    id:{
      eq:$planId
    }
  }){
    nodes{
         schedule {
        events {
          shortDescription
          type
          description
          duration
          isStarred
        }
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception!.linkException!);
      }
      return result.data![planType]['nodes'][0]['schedule'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int?> verifyPlan(
      int planId, PointLatLng coordinate, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  verifyPlan(dto: {
    coordinate:[${coordinate.longitude},${coordinate.latitude}]
    planId:$planId
  }){
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['verifyPlan']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<PointLatLng?> getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
    }

    if (_permissionGranted == PermissionStatus.granted) {
      LocationData _locationData = await _locationController.getLocation();
      if (_locationData.latitude != null) {
        return PointLatLng(_locationData.latitude!, _locationData.longitude!);
      }
    }
  }

  handleShowPlanInformation(
      BuildContext context, LocationViewModel location, PlanCreate? plan) {
    DateTime? _travelDuration =
        sharedPreferences.getDouble('plan_duration_value') != null
            ? DateTime(0, 0, 0).add(Duration(
                seconds:
                    (sharedPreferences.getDouble('plan_duration_value')! * 3600)
                        .toInt()))
            : null;
    showModalBottomSheet(
        context: context,
        builder: (ctx) => ConfirmPlanBottomSheet(
              isFromHost: false,
              isJoin: false,
              locationName: location.name,
              isInfo: true,
              orderList: json.decode(
                  sharedPreferences.getString('plan_temp_order') ?? '[]'),
              listSurcharges: json.decode(
                  sharedPreferences.getString('plan_surcharge') ?? '[]'),
              plan: PlanCreate(
                  endDate: sharedPreferences.getString('plan_end_date') == null
                      ? null
                      : DateTime.parse(
                          sharedPreferences.getString('plan_end_date')!),
                  maxMemberCount: plan == null
                      ? sharedPreferences.getInt('plan_number_of_member')
                      : plan.maxMemberCount,
                  departAt: sharedPreferences.getString('plan_departureDate') ==
                          null
                      ? null
                      : DateTime.parse(
                          sharedPreferences.getString('plan_departureDate')!),
                  name: sharedPreferences.getString('plan_name'),
                  startDate:
                      sharedPreferences.getString('plan_start_date') == null
                          ? null
                          : DateTime.parse(
                              sharedPreferences.getString('plan_start_date')!),
                  schedule: sharedPreferences.getString('plan_schedule'),
                  note: sharedPreferences.getString('plan_note'),
                  savedContacts:
                      sharedPreferences.getString('plan_saved_emergency'),
                  travelDuration: _travelDuration == null
                      ? null
                      : DateFormat.Hm().format(_travelDuration)),
            ));
  }

  handleQuitCreatePlanScreen(void Function() onQuit, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title:
          'Kế hoạch cho chuyến đi chưa được hoàn tất, vẫn rời khỏi màn hình này ?',
      titleTextStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
      padding: EdgeInsets.symmetric(horizontal: 2.h),
      desc: 'Kế hoạch sẽ được lưu lại trong bản nháp',
      descTextStyle: const TextStyle(
          fontSize: 14, color: Colors.grey, fontFamily: 'NotoSans'),
      btnOkColor: Colors.amber,
      btnOkText: "Rời khỏi",
      btnCancelColor: Colors.red,
      btnCancelText: "Hủy",
      btnCancelOnPress: () {},
      btnOkOnPress: onQuit,
    ).show();
  }

  Future<int?> publishPlan(int planId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  changePlanPublishStatus(planId: $planId){
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      return result.data!['changePlanPublishStatus']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }
}
