import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/constants/shedule_item_type.dart';
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
import 'package:intl/intl.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<int> createPlan(PlanCreate model, int planId) async {
    print(model.schedule);
    try {
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
mutation{
  updatePlan(dto: {
    numOfExpPeriod:${model.numOfExpPeriod}
    schedule:${model.schedule}
    id:$planId
    savedContacts:${model.savedContacts}
    departureCoordinate:[
      ${model.longitude},${model.latitude}
    ]
    departureDate: "${model.departureDate.year}-${model.departureDate.month}-${model.departureDate.day} ${model.departureDate.hour}:${model.departureDate.minute}:00.000Z"
    startDate:"${model.startDate.year}-${model.startDate.month}-${model.startDate.day}"
    endDate:"${model.endDate.year}-${model.endDate.month}-${model.endDate.day} 22:00:00.000Z"
    memberLimit:${model.memberLimit}
    name: "${model.name}"
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
        // bool isSuccess = rstext['createPlanDraft']['result']['success'];
        int planId = rstext['updatePlan']['id'];
        sharedPreferences.setInt("planId", planId);
        return planId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> createPlanDraft(PlanCreate model) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
mutation{
  createPlan(dto: {
    numOfExpPeriod: ${model.numOfExpPeriod}
    locationId: ${model.locationId}
    departureCoordinate:[
      ${model.longitude},${model.latitude}
    ]
    departureDate: "${model.departureDate.year}-${model.departureDate.month}-${model.departureDate.day} ${model.departureDate.hour}:${model.departureDate.minute}:00.000Z"
    startDate:"${model.startDate.year}-${model.startDate.month}-${model.startDate.day}"
    endDate:"${model.endDate.year}-${model.endDate.month}-${model.endDate.day}"
    memberLimit:${model.memberLimit}
    name: "${model.name}"
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
        // bool isSuccess = rstext['createPlanDraft']['result']['success'];
        int planId = rstext['createPlan']['id'];
        sharedPreferences.setInt("planId", planId);
        return true;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>> getPlanCardByStatus(String status) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans
    (where: {status:{eq:$status}} order: {id:DESC})
  {
    nodes{
      id
      startDate
      endDate
      location{name imageUrls province{name}}
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

  Future<List<OrderViewModel>> getOrderCreatePlan(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query getOrderDetailsByPlanId(\$planId: Int) {
  orders(where: { planId: { eq: \$planId } }) {
    nodes {
      id
      planId
      deposit
      total
      servingDates
      note
      createdAt
      period
      supplier{
        id
        phone
        name
        type
        thumbnailUrl
        address
      }
      details {
        id
        price
        quantity
        product {
          name
        }
      }
    }
  }
}
"""), variables: {"planId": planId}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['orders']['nodes'];
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
  plans(where: {id: {eq: \$planId}}){
    nodes{
      name
      id
      startDate
      endDate
      schedule
      memberLimit
      savedContacts
      status
      joinMethod
      numOfExpPeriod
      
      departurePosition{
        coordinates
      }
      orders{
        id
      planId
      deposit
      total
      servingDates
      note
      createdAt
      period
      supplier{
        id
        phone
        name
        type
        thumbnailUrl
        address
      }
      details {
        id
        price
        quantity
        product {
          name
        }
      }}
      location{id name imageUrls}
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
      // rs.orders = res[0]["orders"];
      // List<OrderViewModel>? orders = res[0]["orders"].map((order) => OrderViewModel.fromJson(order)).toList();
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
      location{
        name
        imageUrls
        province{
          name
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

  List<PlanSchedule> GetPlanScheduleFromJsonNew(
      List<dynamic> schedules, DateTime startDate, int duration) {
    List<PlanSchedule> schedule = [];
    for (int i = 0; i < duration; i++) {
      List<PlanScheduleItem> item = [];
      final date = startDate.add(Duration(days: i));
      if (i < schedules.length) {
        for (final planItem in schedules[i]) {
          print(planItem['time']);
          item.add(PlanScheduleItem(
            shortDescription: planItem['shortDescription'],
              orderId: planItem['orderGuid'],
              type: schedule_item_types_vn[
                  schedule_item_types.indexOf(planItem['type'].toString())],
              time: TimeOfDay.fromDateTime(DateTime.parse(
                  "1970-01-01 ${planItem['time'].toString().substring(0, 2)}:${planItem['time'].toString().substring(3, 5)}:00")),
              description: planItem['description'],
              date: date));
        }
        item.sort(
          (a, b) {
            var adate = DateTime(0, 0, 0, a.time.hour, a.time.minute);
            var bdate = DateTime(0, 0, 0, b.time.hour, b.time.minute);
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
        items.add({
          'time': json.encode(DateFormat.Hms()
              .format(DateTime(0, 0, 0, item.time.hour, item.time.minute))
              .toString()),
          'orderGuid': item.orderId,
          'description': json.encode(item.description),
          'shortDescription': json.encode(item.shortDescription),
          'type': "GATHER"
        });
      }
      rs.add(items);
    }
    return rs;
  }

  Future<int?> joinPlan(int planId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  joinPlan(planId: $planId){
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
        traveler {
          account {
            name
          }
          phone
        }
        travelerId
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
  changePlanJoinMethod(dto: {
    id: ${planId}
    joinMethod:QR
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
    startDate:"${model.startDate.year}-${model.startDate.month}-${model.startDate.day} ${model.startDate.hour}:${model.startDate.minute}:00.000Z"
    endDate:"${model.endDate.year}-${model.endDate.month}-${model.endDate.day} 22:00:00.000Z"
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
    final duration = endDate.difference(startDate).inDays + 2;
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
    locationId:{
      eq: $locationId
    }
  }){
    nodes{
      id
      name
      leader{
        account{
          name
          id
        }
      }
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
}
