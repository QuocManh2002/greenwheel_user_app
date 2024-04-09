import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/core/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
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
import 'package:location/location.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  final Location _locationController = Location();

  Future<int> createNewPlan(
      PlanCreate model, BuildContext context, String surcharges) async {
    try {
      var schedule = json.decode(model.schedule!);
      final emerIds =
          json.decode(model.savedContacts!).map((e) => e['id']).toList();
      log("""
  mutation{
  createPlan(dto: {
    departureAddress:"${model.departureAddress}"
    departAt:"${model.departureDate!.year}-${model.departureDate!.month}-${model.departureDate!.day} ${model.departureDate!.hour}:${model.departureDate!.minute}:00.000Z"
    departure:[${model.longitude},${model.latitude}]
    destinationId:${model.locationId}
    maxMemberCount:${model.memberLimit}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:$emerIds
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
    maxMemberCount:${model.memberLimit}
    maxMemberWeight:${model.maxMemberWeight!}
    name:"${model.name}"
    note: "${model.note}"
    periodCount:${model.numOfExpPeriod}
    savedProviderIds:$emerIds
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

  Future<Map?> getOrderCreatePlan(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  joinedPlans(where: { id: { eq: $planId } }) {
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

      List? res = result.data!['joinedPlans']['nodes'][0]['orders'];
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
        'currentBudget': result.data!['joinedPlans']['nodes'][0]
            ['actualGcoinBudget']
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
      }

      //       orders{
      //   details{
      //     productId
      //   }
      // }

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
      regCloseAt
      maxMemberCount
      maxMemberWeight
      savedContacts {
        name
        phone
        address
        type
        imagePath
      }
      status
      periodCount
      departDate
      departTime
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
      tempOrders {
        cart
        providerId
        serveDates
        type
        period
        note
        total
      }
      surcharges {
        gcoinAmount
        alreadyDivided
        id
        imagePath
        note
      }
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
          comments{
            id
            comment
            createdAt
            account{
              name
            }
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
      for (final event in sche['events']) {
        eventList.add(PlanScheduleItem(
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
              isStarred: planItem['isStarred'],
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
          'isStarred': item.isStarred,
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
    final duration = endDate.difference(startDate).inDays;
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
  scannablePlans(where: {
    destinationId:{
      eq: $locationId
    }
    status:{
      in:[COMPLETED]
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
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data!['scannablePlans']['nodes'];
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

  Future<List<dynamic>?> getPlanSchedule(
      int planId, String type) async {
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
      }
      log("""
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
}""");
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

  Future<int?> verifyPlan(int planId, PointLatLng coordinate, BuildContext context)async{
    try{
      QueryResult result = await client.mutate(
        MutationOptions(document: gql('''
mutation{
  verifyPlan(dto: {
    coordinate:[${coordinate.longitude},${coordinate.latitude}]
    planId:$planId
  }){
    id
  }
}
'''))
      );
      if(result.hasException){
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['verifyPlan']['id'];
    }catch (error) {
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
}

