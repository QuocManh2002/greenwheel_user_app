import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/suggest_plan.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<int> createNewPlan(
      PlanCreate model, BuildContext context, String surcharges) async {
    try {
      var schedule = json.decode(model.schedule!);
      log("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departureAddress}"
    departAt:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    gcoinBudgetPerCapita:${model.gcoinBudget}
    maxMember:${model.memberLimit}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedContacts:${json.decode(model.savedContacts!).toString()}
    schedule:$schedule
    surcharges:$surcharges
    tempOrders:${model.tempOrders}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}
""");

      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departureAddress}"
    departAt:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    gcoinBudgetPerCapita:${model.gcoinBudget}
    maxMember:${model.memberLimit}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedContacts:${json.decode(model.savedContacts!).toString()}
    schedule:$schedule
    surcharges:$surcharges
    tempOrders:${model.tempOrders}
    travelDuration:"${model.travelDuration}"
  }){
    id
  }
}
"""),
      ));
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        int planId = rstext['createPlan']['id'];
        return planId;
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      Utils().handleServerException(
          'Đã xảy ra lỗi trong lúc tạo kế hoạch', context);
      throw Exception(error);
    }
  }

  Future<Map?> getOrderCreatePlan(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(where: { id: { eq: $planId } }) {
    nodes {
      currentGcoinBudget
      orders {
        id
        planId
        total
        serveDates
        note
        createdAt
        period
        type
        supplier {
          type
          id
          phone
          name
          imageUrl
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
        throw Exception(result.exception);
      }

      List? res = result.data!['plans']['nodes'][0]['orders'];
      if (res == null) {
        return null;
      }
      List<OrderViewModel>? orders = [];
      for (final item in res) {
        OrderViewModel order = OrderViewModel.fromJson(item);
        List<OrderDetailViewModel>? details = [];
        for (final detail in item['details']) {
          details.add(OrderDetailViewModel.fromJson(detail));
        }
        order.details = details;
        orders.add(order);
      }
      return {
        'orders': orders,
        'currentBudget': result.data!['plans']['nodes'][0]['currentGcoinBudget']
      };
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<PlanDetail?> GetPlanById(int planId) async {
    try {
      QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
  plans(where: { id: { eq: $planId } }) {
    nodes {
      name
      id
      startDate
      endDate
      departureAddress
      accountId
      account{
        name
      }
      joinMethod
      gcoinBudgetPerCapita
      currentGcoinBudget
      travelDuration
      note
      memberCount
      regClosedAt
      schedule {
        events {
          shortDescription
          type
          description
          duration
        }
      }
      maxMember
      maxMemberWeight
      savedContacts {
        name
        phone
        address
        type
        imageUrl
      }
      status
      periodCount
      departAt
      departure {
        coordinates
      }
      destination {
        id
        name
        imageUrls
      }
      members {
        status
        weight
        account {
          avatarUrl
          id
          name
          phone
        }
        id
      }
      tempOrders{
        cart
        type
        serveDates
        period
        note
      }
      surcharges{
          amount
          note
        }
    }
  }
}

"""),
      ));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['plans']['nodes'];
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

  Future<List<PlanCardViewModel>?> getPlanCards(int accountId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(first: 50
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
          imageUrls
          name
          activities
          seasons
          topographic
          coordinate{coordinates}
          address
          province{
            id
            name
            imageUrl
          }
          emergencyContacts{
            name
            phone
            address
            type
          }
          comments{
            id
            comment
            createdAt
            account{
              avatarUrl
              name
            }
          }
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['plans']['nodes'];
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
      for (final event in sche['events']) {
        eventList.add(PlanScheduleItem(
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
    return list;
  }

  List<PlanSchedule> GetPlanScheduleFromJsonNew(
      List<dynamic> schedules, DateTime startDate, int duration) {
    List<PlanSchedule> schedule = [];
    for (int i = 0; i < duration; i++) {
      List<PlanScheduleItem> item = [];
      final date = startDate.add(Duration(days: i));
      if (i < schedules.length) {
        for (final planItem in schedules[i]['events']) {
          item.add(PlanScheduleItem(
              activityTime:
                  int.parse(planItem['duration'].toString().substring(0, 2)),
              shortDescription: planItem['shortDescription'],
              type: schedule_item_types_vn[
                  schedule_item_types.indexOf(planItem['type'].toString())],
              time: TimeOfDay.fromDateTime(DateTime.parse(
                  "1970-01-01 ${planItem['duration'].toString().substring(0, 2)}:${planItem['duration'].toString().substring(3, 5)}:00")),
              description: planItem['description'],
              date: date));
        }
        item.sort(
          (a, b) {
            var adate = DateTime(0, 0, 0, a.time!.hour, a.time!.minute);
            var bdate = DateTime(0, 0, 0, b.time!.hour, b.time!.minute);
            return adate.compareTo(bdate);
          },
        );
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
        items.add({
          'isStarred': false,
          'duration': json.encode("${item.activityTime}:00:00"),
          'description': json.encode(item.description),
          'shortDescription': json.encode(item.shortDescription),
          'type': schedule_item_types[schedule_item_types_vn.indexOf(type)]
        });
        print(schedule_item_types[schedule_item_types_vn.indexOf(type)]);
      }
      rs.add({"events": items});
    }
    return rs;
  }

  Future<int?> joinPlan(int planId, int weight, List<String> names) async {
    final listName = names.map((e) => json.encode(e)).toList();
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  joinPlan(dto: {
    companions:${listName.isEmpty ? null : listName}
    planId: $planId
    weight: $weight
  }){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
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

  Future<List<PlanMemberViewModel>> getPlanMember(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(where: { id: { eq: $planId } }) {
    nodes {
      members {
        status
        weight
        companions
        account {
          name
          phone
          id
        }
        id
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['plans']['nodes'][0]['members'];
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

  Future<bool> updateJoinMethod(int planId, String method) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  changePlanJoinMethod(dto: {
    joinMethod:$method,
    planId:$planId
  }){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      int? res = result.data!['changePlanJoinMethod']['id'];
      if (res == null || res == 0) {
        return false;
      }
      return true;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> inviteToPlan(int planId, int travelerId) async {
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
        throw Exception(result.exception);
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
    final duration = endDate.difference(startDate).inDays;
    List<PlanSchedule> result = [];
    for (int i = 0; i < duration; i++) {
      result
          .add(PlanSchedule(date: startDate.add(Duration(days: i)), items: []));
    }
    return result;
  }

  Future<List<SuggestPlanViewModel>> getSuggestPlanByLocation(
      int locationId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(where: {
    destinationId:{
      eq: $locationId
    }
    status:{
      in:[FLAWED COMPLETED]
    }
  }){
    nodes{
      id
      name
      startDate
      endDate
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['plans']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<SuggestPlanViewModel> plans =
          res.map((plan) => SuggestPlanViewModel.fromJson(plan)).toList();
      return plans;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String> publicizePlan(int planId) async {
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
        throw Exception(result.exception);
      }

      String? res = result.data!['publicizePlan']['status'];
      return res!;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> confirmMember(int planId) async {
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
        throw Exception(result.exception);
      }

      int? res = result.data!['confirmMembers']['id'];
      return res!;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> removeMember(int memberId, bool isBlock) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation{
  removeMember(dto: {
    planMemberId:$memberId
    shouldBeBlocked:$isBlock
  }){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
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
}
