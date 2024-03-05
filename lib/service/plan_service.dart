import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
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
      print("""
  mutation{
  createPlan(dto: {
    departAt:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    gcoinBudgetPerCapita:${model.gcoinBudget}
    memberLimit:${model.memberLimit}
    name:"${model.name}"
    note:"${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedContacts:${json.decode(model.savedContacts!).toString()}
    schedule:$schedule
    surcharges:$surcharges
    tempOrders:${model.tempOrders}
    travelDuration:"${model.travelDuration}"
    weight:${model.weight}
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
    departAt:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    gcoinBudgetPerCapita:${model.gcoinBudget}
    memberLimit:${model.memberLimit}
    name:"${model.name}"
    note:"${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedContacts:${json.decode(model.savedContacts!).toString()}
    schedule:$schedule
    surcharges:$surcharges
    tempOrders:${model.tempOrders}
    travelDuration:"${model.travelDuration}"
    weight:${model.weight}
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

  Future<int> createDraftPlan(PlanCreate model) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
mutation{
  createDraftPlan(dto: {
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    memberLimit:${model.memberLimit}
    periodCount:${model.numOfExpPeriod}
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
        int planId = rstext['createDraftPlan']['id'];
        sharedPreferences.setInt("planId", planId);
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> completeCreatePlan(
      PlanCreate model, int planId, String surcharges) async {
    try {
      DateTime _travelDuration = DateTime(0, 0, 0).add(Duration(
          seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
              .toInt()));
      var schedule = json.decode(model.schedule!);
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
  mutation{
  completeCreatePlan(dto: {
    travelDuration:"${_travelDuration.hour.toString().length == 1 ? '0${_travelDuration.hour}' : _travelDuration.hour}:${_travelDuration.minute.toString().length == 1 ? '0${_travelDuration.minute}' : _travelDuration.minute}"
    gcoinBudgetPerCapita: ${model.gcoinBudget}
    id:$planId
    name:"${model.name}"
    savedContacts:${model.savedContacts}
    schedule:$schedule
    surcharges:$surcharges
    departDate:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
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
        int planId = rstext['completeCreatePlan']['id'];
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<OrderViewModel>> getOrderCreatePlan(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(where: { id: { eq: $planId } }) {
    nodes {
      orders {
        id
        planId
        total
        serveDateIndexes
        note
        createdAt
        period
        type
        supplier {
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
      if (res == null || res.isEmpty) {
        return [];
      }
      List<OrderViewModel>? orders = [];
      // List<OrderViewModel> orders =
      //     res.map((order) => OrderViewModel.fromJson(order)).toList();
      for (final item in res) {
        OrderViewModel order = OrderViewModel.fromJson(item);
        List<OrderDetailViewModel>? details = [];
        for (final detail in item['details']) {
          details.add(OrderDetailViewModel.fromJson(detail));
        }
        order.details = details;
        orders.add(order);
      }
      return orders;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<PlanDetail?> GetPlanById(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query GetPlanById(\$planId: Int){
  plans(where: { id: { eq: \$planId } }) {
    nodes {
      name
      id
      startDate
      endDate
      isPublic
      accountId
      gcoinBudgetPerCapita
      travelDuration
      note
      memberCount
      schedule {
        events {
          shortDescription
          type
          description
          duration
        }
      }
      memberLimit
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
      orders {
        id
        planId
        deposit
        total
        serveDateIndexes
        note
        createdAt
        period
        supplier {
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
            name
            type
            price
          }
        }
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
          id
          name
          phone
        }
        id
      }
      tempOrders{
        cart
        type
        serveDateIndexes
        period
        note
      }
    }
  }
}

"""), variables: {"planId": planId}));

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
      List<OrderViewModel>? orders = [];
      for (final item in res[0]["orders"]) {
        List<OrderDetailViewModel>? details = [];
        OrderViewModel order = OrderViewModel.fromJson(item);
        for (final detail in item["details"]) {
          details.add(OrderDetailViewModel.fromJson(detail));
        }
        order.details = details;
        orders.add(order);
      }
      rs.orders = orders;
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>?> getPlanCards() async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(first: 50){
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
    // var _schedule = schedules;
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
      DateTime startDate, String scheduleText) {
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
          // print(planItem['time']);
          item.add(PlanScheduleItem(
              activityTime:
                  int.parse(planItem['duration'].toString().substring(0, 2)),
              shortDescription: planItem['shortDescription'],
              // orderId: planItem['orderGuid'],
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
          'duration':
              // json.encode(DateFormat.Hms()
              //     .format(DateTime(0, 0, 0, item.time.hour, item.time.minute))
              //     .toString()),
              json.encode("${item.activityTime}:00:00"),
          // 'orderGuid': item.orderId == null ? null: json.encode(item.orderId),
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

  Future<int?> joinPlan(int planId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  joinPlan(dto: {
    planId: $planId
    weight: 1
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

  Future<bool> updateJoinMethod(int planId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  updatePlanJoinMethod(dto: {
    joinMethod:SCAN,
    planId:$planId
  }){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      int? res = result.data!['updatePlanJoinMethod']['id'];
      if (res == null || res == 0) {
        return false;
      }
      return true;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> updateEmergencyService(
      PlanCreate model, String serviceList, int planId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  updatePlan(dto: {
    id: $planId
    latitude: ${model.latitude}
    longitude: ${model.longitude} 
    startDate:"${model.startDate!.year}-${model.startDate!.month}-${model.startDate!.day} ${model.startDate!.hour}:${model.startDate!.minute}:00.000Z"
    endDate:"${model.endDate!.year}-${model.endDate!.month}-${model.endDate!.day} 22:00:00.000Z"
    memberLimit:${model.memberLimit}
    name: ${json.encode(model.name)}
    schedule:${model.schedule}
    savedContacts: $serviceList
  }){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        int planId = rstext['updatePlan']['id'];
        return planId;
      }
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
    id:$planId
    travelerId:$travelerId
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
      in:[READY VERIFIED PUBLISHED PENDING]
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

  Future<bool> publicizePlan(int planId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  publicizePlan(planId: $planId){
    id
    isPublic
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      bool? res = result.data!['publicizePlan']['isPublic'];
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
    isPublic
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
