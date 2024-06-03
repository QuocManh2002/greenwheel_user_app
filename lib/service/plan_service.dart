// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/shedule_item_type.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/main.dart';
import 'package:phuot_app/service/order_service.dart';
import 'package:phuot_app/view_models/location.dart';
import 'package:phuot_app/view_models/order.dart';
import 'package:phuot_app/view_models/plan_member.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:phuot_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:phuot_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sizer2/sizer2.dart';

import '../core/constants/combo_date_plan.dart';
import '../core/constants/global_constant.dart';
import '../core/constants/service_types.dart';
import '../core/constants/sessions.dart';
import '../screens/plan_screen/create_plan/select_start_location_screen.dart';
import '../widgets/plan_screen_widget/update_order_clone_plan_bottom_sheet.dart';
import '../widgets/style_widget/dialog_style.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  final Location _locationController = Location();
  final OrderService _orderService = OrderService();

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
    schedule:${convertToFinalSchedule(schedule)}
    surcharges:$surcharges
    travelDuration:"${model.travelDuration}"
    tempOrders:${_orderService.convertTempOrders(model.tempOrders ?? [], model.startDate!)}
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
    schedule:${convertToFinalSchedule(schedule)}
    surcharges:$surcharges
    travelDuration:"${model.travelDuration}"
    tempOrders:${_orderService.convertTempOrders(model.tempOrders ?? [], model.startDate!)}
    ${model.sourceId != null ? 'sourceId: ${model.sourceId}' : ''}
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
    schedule:${convertToFinalSchedule(schedule)}
    surcharges:$surcharges
    travelDuration:"${model.travelDuration}"
    sourceId:${sharedPreferences.getInt('planId')}
    tempOrders:${_orderService.convertTempOrders(model.tempOrders ?? [], model.startDate!)}
  }){
    id
  }
}
""");
      GraphQLClient client = graphQlConfig.getClient();
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
    schedule:${convertToFinalSchedule(schedule)}
    surcharges:$surcharges
    travelDuration:"${model.travelDuration}"
    sourceId:${sharedPreferences.getInt('planId')}
    tempOrders:${_orderService.convertTempOrders(model.tempOrders ?? [], model.startDate!)}
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

  Future<PlanDetail?> getPlanById(int planId, String type) async {
    try {
      String planType = '';
      switch (type) {
        case "JOIN":
          planType = 'joinedPlans';
          break;
        case "OWN":
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
      GraphQLClient newClient = await graphQlConfig.getOfflineClient();
      QueryResult result = await newClient.query(QueryOptions(
        document: gql("""
{
  $planType(
    where: { 
      id: { eq: $planId } 
      ${type == 'INVITATION' ? 'joinMethod:{neq:NONE}' : ''}
      ${type == 'SCAN' ? 'joinMethod:{eq:SCAN}' : ''}
    }) {
    nodes {
      name
      id
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
        providerId
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
        coordinate{
          coordinates
        }
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
        gcoinAmount
        id
        imagePath
        note
      }
      utcRegCloseAt
      utcDepartAt
      utcStartAt
      utcEndAt
      schedule
      isPublished
      tempOrders{
        cart
        uuid
        type
        providerId
        serveDateIndexes
        period
        note
        totalGcoin
      }
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
        uuid
        provider {
          coordinate{
            coordinates
          }
          type
          id
          phone
          name
          imagePath
          address
          isActive
        }
        details {
          id
          price
          quantity
          product {
            id
            partySize
            name
            type
            price
            isAvailable
          }
        }
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

  Future<List<PlanCardViewModel>?> getPlanCards(bool isOwned) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
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
      status
      utcDepartAt
      utcEndAt
      periodCount
      gcoinBudgetPerCapita
      destination{
          name
      }
    }
  }
}
""")));
      if (result.hasException) {
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

  List<List<String>> getPlanDetailFormJson(List<dynamic> details) {
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

  List<PlanSchedule> getPlanScheduleClone(List<PlanSchedule> schedules) {
    for (final schedule in schedules) {
      if (schedule.items.isNotEmpty) {
        for (int i = 0; i < schedule.items.length; i++) {
          schedule.items.removeWhere((element) => element.orderId != null);
        }
      }
    }
    return schedules;
  }

  List<PlanSchedule> convertPLanJsonToObject(
      int duration, DateTime startDate, String scheduleText) {
    List<PlanSchedule> list = [];
    List<dynamic> scheduleList = json.decode(scheduleText);
    for (final sche in scheduleList) {
      List<PlanScheduleItem> eventList = [];
      for (final event in sche) {
        // final duration = DateFormat.Hm().parse(json.decode(event['duration']));
        final duration = DateFormat.Hm().parse(event['duration']);

        eventList.add(PlanScheduleItem(
            orderUUID: event['orderUUID'],
            isStarred: event['isStarred'],
            activityTime:
                Duration(hours: duration.hour, minutes: duration.minute),
            // description: json.decode(event['description']),
            // shortDescription: json.decode(event['shortDescription']),
            description: event['description'],
            shortDescription: event['shortDescription'],
            type: scheduleItemTypesVn[scheduleItemTypes.indexOf(event['type'])],
            date: startDate.add(Duration(days: scheduleList.indexOf(sche)))));
      }
      list.add(PlanSchedule(
          date: startDate.add(Duration(days: scheduleList.indexOf(sche))),
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

  List<PlanSchedule> getPlanScheduleFromJsonNew(
      List<dynamic> schedules, DateTime startDate, int duration) {
    List<PlanSchedule> schedule = [];
    for (int i = 0; i < duration; i++) {
      List<PlanScheduleItem> item = [];
      final date = startDate.add(Duration(days: i));
      if (i < schedules.length) {
        for (final planItem in schedules[i]) {
          final duration = DateFormat.Hm().parse(planItem['duration']);
          item.add(PlanScheduleItem(
              orderUUID: planItem['orderUUID'].toString().substring(0, 1) == '"'
                  ? json.decode(planItem['orderUUID'])
                  : planItem['orderUUID'],
              isStarred: planItem['isStarred'],
              activityTime:
                  Duration(hours: duration.hour, minutes: duration.minute),
              shortDescription:
                  planItem['shortDescription'].toString().substring(0, 1) == '"'
                      ? json.decode(planItem['shortDescription'])
                      : planItem['shortDescription'],
              type: scheduleItemTypesVn[
                  scheduleItemTypes.indexOf(planItem['type'].toString())],
              description:
                  planItem['description'].toString().substring(0, 1) == '"'
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
        final type =
            scheduleItemTypesVn.firstWhere((element) => element == item.type);
        items.add({
          'orderUUID': item.orderUUID,
          'isStarred': item.isStarred,
          'duration': DateFormat.Hm().format(DateTime(
              0,
              0,
              0,
              item.activityTime!.inHours,
              item.activityTime!.inMinutes.remainder(60))),
          'description': item.description,
          'shortDescription': item.shortDescription,
          'type': scheduleItemTypes[scheduleItemTypesVn.indexOf(type)]
        });
      }
      rs.add(items);
    }
    return rs;
  }

  List<dynamic> convertToFinalSchedule(List<dynamic> list) {
    List<dynamic> rs = [];
    for (final schedule in list) {
      var items = [];
      for (final item in schedule) {
        final type =
            scheduleItemTypes.firstWhere((element) => element == item['type']);
        items.add({
          'orderUUID':
              item['orderUUID'] == null ? null : json.encode(item['orderUUID']),
          'isStarred': item['isStarred'],
          'duration': json.encode(item['duration']),
          'description': json.encode(item['description']),
          'shortDescription': json.encode(item['shortDescription']),
          'type': type
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
      GraphQLClient client = graphQlConfig.getClient();
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
        case "OWN":
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
      GraphQLClient client = graphQlConfig.getClient();
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
      GraphQLClient client = graphQlConfig.getClient();
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

  Future<List<PlanCardViewModel>?> getSuggestPlanByLocation(
      int locationId, BuildContext context) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  publishedPlans(
    where: { destinationId: { eq: $locationId } }
    order: { periodCount: ASC }
  ) {
    edges {
      node {
        id
        name
        periodCount
        gcoinBudgetPerCapita
        destination {
          name
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

      List? res = result.data!['publishedPlans']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<PlanCardViewModel> plans =
          res.map((plan) => PlanCardViewModel.fromJson(plan['node'])).toList();
      return plans;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>> filterPublishedPLans(
      int minAmount,
      int maxAmount,
      int periodCount,
      int locationId,
      BuildContext context) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  publishedPlans(
    where: {
      destinationId: { eq: $locationId }
      or: [
        { periodCount: { in: [$periodCount, ${periodCount + 1}] } }
        { gcoinBudgetPerCapita: { gte: $minAmount, lte: $maxAmount } }
      ]
    }
    order: { periodCount: ASC }
  ) {
    edges {
      node {
        id
        name
        periodCount
        gcoinBudgetPerCapita
        destination {
          name
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

      List? res = result.data!['publishedPlans']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<PlanCardViewModel> plans =
          res.map((plan) => PlanCardViewModel.fromJson(plan['node'])).toList();
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
      String? surchargeImagePath = result.data!['updateSurcharge']['imagePath'];
      if (surchargeImagePath == null) {
        return null;
      }
      return surchargeImagePath;
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
        case "OWN":
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
      log('''
mutation{
  verifyPlan(dto: {
    coordinate:[${coordinate.longitude},${coordinate.latitude}]
    planId:$planId
  }){
    id
  }
}
''');
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
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    }
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await _locationController.getLocation();
      if (locationData.latitude != null) {
        return PointLatLng(locationData.latitude!, locationData.longitude!);
      }
    }
    return null;
  }

  handleShowPlanInformation(BuildContext context, LocationViewModel location,
      bool isClone, PlanCreate? plan) async {
    final OrderService orderService = OrderService();
    List<OrderViewModel> orders = [];
    List<SurchargeViewModel> surcharges = [];
    if (plan == null) {
      final orderList =
          json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
      orders = orderService.getOrderFromJson(orderList);
      final surchargeList =
          json.decode(sharedPreferences.getString('plan_surcharge') ?? '[]');
      surcharges = List<SurchargeViewModel>.from(surchargeList.map(
          (surcharge) => SurchargeViewModel.fromJsonLocal(surcharge))).toList();
    }
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: SizedBox(
                height: 10.h,
                width: 100.w,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ),
            ));
    if (plan == null) {
      await orderService.updateProductPrice(context, plan != null);
    }
    Navigator.of(context).pop();
    DateTime? travelDuration =
        sharedPreferences.getDouble('plan_duration_value') != null
            ? DateTime(0, 0, 0).add(Duration(
                minutes:
                    (sharedPreferences.getDouble('plan_duration_value')! * 60)
                        .toInt()))
            : null;
    DateTime? departDate = sharedPreferences.getString('plan_departureDate') ==
            null
        ? null
        : DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    DateTime? departTime = sharedPreferences.getString('plan_departureTime') ==
            null
        ? null
        : DateTime.parse(sharedPreferences.getString('plan_departureTime')!);

    showModalBottomSheet(
        context: context,
        backgroundColor: lightPrimaryTextColor,
        builder: (ctx) => ConfirmPlanBottomSheet(
              isFromHost: false,
              isJoin: false,
              locationName: location.name,
              isInfo: true,
              orderList: orders,
              surchargeList: surcharges,
              plan: plan ??
                  PlanCreate(
                      numOfExpPeriod:
                          sharedPreferences.getInt('initNumOfExpPeriod'),
                      tempOrders: orders,
                      surcharges: surcharges,
                      endDate: sharedPreferences.getString('plan_end_date') ==
                              null
                          ? null
                          : DateTime.parse(
                              sharedPreferences.getString('plan_end_date')!),
                      maxMemberCount: plan == null
                          ? isClone
                              ? sharedPreferences
                                      .getInt('plan_number_of_member') ??
                                  sharedPreferences
                                      .getInt('init_plan_number_of_member')
                              : sharedPreferences
                                  .getInt('plan_number_of_member')
                          : plan.maxMemberCount,
                      departAt: departDate == null
                          ? null
                          : DateTime(departDate.year, departDate.month, departDate.day)
                              .add(Duration(hours: departTime!.hour))
                              .add(Duration(minutes: departTime.minute)),
                      name: sharedPreferences.getString('plan_name'),
                      startDate:
                          sharedPreferences.getString('plan_start_date') == null
                              ? null
                              : DateTime.parse(sharedPreferences
                                  .getString('plan_start_date')!),
                      schedule: sharedPreferences.getString('plan_schedule'),
                      note: sharedPreferences.getString('plan_note'),
                      departAddress:
                          sharedPreferences.getString('plan_start_address'),
                      savedContacts:
                          sharedPreferences.getString('plan_saved_emergency'),
                      travelDuration: travelDuration == null
                          ? null
                          : DateFormat.Hm().format(travelDuration)),
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

  Future<List<int>?> getReadyPlanIds(BuildContext context) async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  ownedPlans(where: {
    status:{
      eq:READY
    }
  }) {
    edges {
      node {
        id
      }
    }
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      List<int> rs = [];
      for (final plan in result.data!['ownedPlans']['edges']) {
        rs.add(plan['node']['id']);
      }
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>?> searchPLans(
      String searchText, BuildContext context) async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  joinedPlans(
    first: 50
    order: { id: DESC }
    where: { name: { contains: "$searchText" } }
  ) {
    nodes {
      id
      name
      status
      utcDepartAt
      utcEndAt
      periodCount
      gcoinBudgetPerCapita
      destination {
        name
      }
    }
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      List? res = result.data!['joinedPlans']['nodes'];
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

  setUpDataClonePlan(PlanDetail plan, List<bool> options) {
    final OrderService orderService = OrderService();
    sharedPreferences.setString('plan_clone_options', json.encode(options));
    sharedPreferences.setInt('planId', plan.id!);
    sharedPreferences.setString('plan_location_name', plan.locationName!);
    sharedPreferences.setInt('plan_location_id', plan.locationId!);
    sharedPreferences.setInt('maxCombodateValue', plan.numOfExpPeriod!);
    sharedPreferences.setInt(
        'init_plan_number_of_member', plan.maxMemberCount!);

    sharedPreferences.setInt('initNumOfExpPeriod', plan.numOfExpPeriod!);
    sharedPreferences.setInt(
        'plan_combo_date',
        listComboDate
                .firstWhere(
                    (element) => element.duration == plan.numOfExpPeriod)
                .id -
            1);
    sharedPreferences.setInt('plan_number_of_member', plan.maxMemberCount!);
    sharedPreferences.setInt('plan_max_member_weight', plan.maxMemberWeight!);

    sharedPreferences.setDouble('plan_start_lat', plan.startLocationLat!);
    sharedPreferences.setDouble('plan_start_lng', plan.startLocationLng!);
    sharedPreferences.setString('plan_start_address', plan.departureAddress!);
    sharedPreferences.setString(
        'plan_departureTime', plan.utcDepartAt!.toLocal().toString());

    sharedPreferences.setString('plan_name', plan.name!);

    if (options[4]) {
      sharedPreferences.setStringList('selectedIndex',
          plan.savedContacts!.map((e) => e.providerId.toString()).toList());
    }

    if (options[5]) {
      sharedPreferences.setBool('notAskScheduleAgain', false);
      if (options[6]) {
        final availableOrder = plan.orders!
            .where((e) =>
                e.supplier!.isActive! &&
                e.details!.every((element) => element.isAvailable!))
            .toList();
        final list = availableOrder.map((order) {
          final orderDetailGroupList =
              order.details!.groupListsBy((e) => e.productId);
          final orderDetailList =
              orderDetailGroupList.entries.map((e) => e.value.first).toList();
          return orderService.convertToTempOrder(
              order.supplier!,
              order.note ?? "",
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
              order.total! / GlobalConstant().VND_CONVERT_RATE);
        }).toList();
        for (final date in plan.schedule!) {
          for (final item in date) {
            if (item['orderUUID'] != null &&
                !availableOrder
                    .any((element) => element.uuid == item['orderUUID'])) {
              item['orderUUID'] = null;
            }
          }
        }
        sharedPreferences.setString('plan_temp_order', json.encode(list));
      } else {
        sharedPreferences.setString('plan_temp_order', '[]');

        for (final date in plan.schedule!) {
          for (final item in date) {
            if (item['orderUUID'] != null) {
              item['orderUUID'] = null;
            }
          }
        }
      }
      sharedPreferences.setString('plan_schedule', json.encode(plan.schedule));
    }

    if (options[7]) {
      sharedPreferences.setString(
          'plan_surcharge',
          json.encode(
              plan.surcharges!.map((e) => e.toJsonWithoutImage()).toList()));
    }
    sharedPreferences.setString('plan_note', plan.note ?? 'null');
  }

  handleAlreadyDraft(BuildContext context, LocationViewModel location,
      String locationName, bool isClone, PlanDetail? plan, List<bool> options) {
    DialogStyle().basicDialog(
      context: context,
      type: DialogType.question,
      title:
          'Bạn đang có bản nháp chuyến đi tại ${locationName == location.name ? 'địa điểm này' : locationName}',
      desc: 'Bạn có muốn ghi đè chuyến đi đó không ?',
      onOk: () {
        Utils().clearPlanSharePref();
        sharedPreferences.setString('plan_location_name', location.name);
        sharedPreferences.setInt('plan_location_id', location.id);
        if (isClone) {
          setUpDataClonePlan(plan!, options);
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SelectStartLocationScreen(
                  isCreate: true,
                  location: location,
                  isClone: isClone,
                )));
      },
      btnOkColor: Colors.deepOrangeAccent,
      btnOkText: 'Có',
      btnCancelColor: Colors.blueAccent,
      btnCancelText: 'Không',
      onCancel: () {
        if (locationName == location.name) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => SelectStartLocationScreen(
                    isCreate: true,
                    location: location,
                    isClone: isClone,
                  )));
        }
      },
    );
  }

  updateScheduleAndOrder(BuildContext context, void Function() onConfirm,
      bool isChangeDate) async {
    final OrderService orderService = OrderService();
    int newDuration =
        (sharedPreferences.getInt('initNumOfExpPeriod')! / 2).ceil();
    var schedule =
        json.decode(sharedPreferences.getString('plan_schedule') ?? '[]');
    var tempOrders =
        json.decode(sharedPreferences.getString('plan_temp_order')!);
    final isPlanEndAtNoon = Utils().isEndAtNoon(null);
    var newSchedule = [];

    for (int i = 0; i < newDuration; i++) {
      if (i < newDuration - 1) {
        newSchedule.add(schedule[i]);
      }
    }
    newSchedule.add(schedule.last);

    var updatedOrders = [];
    var canceledOrders = [];
    for (final order in tempOrders) {
      final newIndexes = [];
      final invalidIndexes = [];
      for (final index in order['serveDateIndexes']) {
        if (order['type'] == services[0].name) {
          if (index < newDuration - 1) {
            newIndexes.add(index);
          } else if (index >= newDuration - 1 && index < schedule.length - 1) {
            invalidIndexes.add(index);
          }

          if (index == schedule.length - 1 &&
              isPlanEndAtNoon &&
              (order['period'] == sessions[0].enumName ||
                  order['period'] == sessions[1].enumName)) {
            newIndexes.add(newDuration - 1);
          }
        } else if ((order['type'] == services[1].name ||
                order['type'] == services[2].name) &&
            index < newDuration - 1) {
          newIndexes.add(index);
        } else {
          invalidIndexes.add(index);
        }
      }
      if (newIndexes.isNotEmpty && newIndexes != order['serveDateIndexes']) {
        final startDate =
            DateTime.parse(sharedPreferences.getString('plan_start_date')!);
        order['newIndexes'] = newIndexes;
        order['newServeDates'] = newIndexes
            .map((e) => startDate.add(Duration(days: e)).toString())
            .toList();
        order['invalidIndexes'] = invalidIndexes;
        order['newTotal'] = orderService.getTempOrderTotal(order, true);
        updatedOrders.add(order);
      } else {
        order['cancelReason'] = 'Ngoài ngày phục vụ';
        canceledOrders.add(order);
      }
    }
    final arrivedText = sharedPreferences.getString('plan_arrivedTime');
    if (arrivedText != null) {
      final arrivedTime = DateTime.parse(arrivedText);
      final startSession = sessions.firstWhereOrNull((aTime) =>
              aTime.from <= arrivedTime.hour && aTime.to > arrivedTime.hour) ??
          sessions[0];
      bool endAtNoon = Utils().isEndAtNoon(null);
      final endSession = endAtNoon ? sessions[1] : sessions.last;

      for (final item in newSchedule[0]) {
        if (item['orderUUID'] != null) {
          final order =
              tempOrders.firstWhere((e) => e['orderUUID'] == item['orderUUID']);
          final session = sessions
              .firstWhere((element) => element.enumName == order['period']);
          if (session.index < startSession.index) {
            if (updatedOrders
                .any((element) => element['orderUUID'] == item['orderUUID'])) {
              order['newIndexes'].remove(order['newIndexes'].first);
              order['newServeDates'].remove(order['newServeDates'].first);
            } else {
              order['newIndexes'] = order['serveDateIndexes']
                  .remove(order['serveDateIndexes'].first);
              order['newServeDates'] =
                  order['serveDates'].remove(order['serveDates'].first);
              updatedOrders.add(order);
            }
            order['newTotal'] = orderService.getTempOrderTotal(order, true);
          }
        }
      }
      for (final item in newSchedule.last) {
        if (item['orderUUID'] != null) {
          final order =
              tempOrders.firstWhere((e) => e['orderUUID'] == item['orderUUID']);
          final session = sessions
              .firstWhere((element) => element.enumName == order['period']);
          if (session.index > endSession.index &&
              (order['type'] == services[0].name ||
                  order['type'] == services[2].name)) {
            if (updatedOrders
                .any((element) => element['orderUUID'] == item['orderUUID'])) {
              order['newIndexes'].remove(order['newIndexes'].last);
              order['newServeDates'].remove(order['newServeDates'].last);
            } else {
              order['newIndexes'] = order['serveDateIndexes']
                  .remove(order['serveDateIndexes'].last);
              order['newServeDates'] =
                  order['serveDates'].remove(order['serveDates'].last);
              updatedOrders.add(order);
            }
            order['newTotal'] = orderService.getTempOrderTotal(order, true);
          }
        }
      }
    }
    if (updatedOrders.isNotEmpty || canceledOrders.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => UpdateOrderClonePlanBottomSheet(
          cancelOrders: canceledOrders,
          updatedOrders: updatedOrders,
          onConfirm: () async {
            for (final order in canceledOrders) {
              tempOrders.removeWhere(
                  (element) => element['orderUUID'] == order['orderUUID']);
              for (final date in newSchedule) {
                for (final item in date) {
                  if (item['orderUUID'] == order['orderUUID']) {
                    item['orderUUID'] = null;
                  }
                }
              }
            }
            for (final order in updatedOrders) {
              var temp = tempOrders.firstWhere(
                  (element) => element['orderUUID'] == order['orderUUID']);
              final index = tempOrders.indexOf(temp);
              tempOrders[index]['total'] = order['newTotal'];
              tempOrders[index]['serveDates'] = order['newServeDates'];
              tempOrders[index]['details'] = order['newDetails'];
              tempOrders[index]['serveDateIndexes'] = order['newIndexes'];

              if (isChangeDate && order['type'] == services[1].name) {
                final List<List<DateTime>> splitServeDates =
                    Utils().splitCheckInServeDates(order['newServeDates']);
                final endDate = DateTime.parse(
                    sharedPreferences.getString('plan_end_date')!);
                final startDate = DateTime.parse(
                    sharedPreferences.getString('plan_start_date')!);
                for (final dateList in splitServeDates) {
                  if (!newSchedule[dateList.first.difference(startDate).inDays]
                      .any((element) =>
                          element['orderUUID'] == order['orderUUID'])) {
                    await newSchedule[
                            dateList.first.difference(startDate).inDays]
                        .add({
                      'isStarred': false,
                      'shortDescription': 'Check-in',
                      'description': 'Check-in nhà nghỉ/khách sạn',
                      'type': 'CHECKIN',
                      'orderUUID': order['orderUUID'],
                      'duration': '00:30:00'
                    });
                  }
                  if (dateList.last == endDate) {
                    if (!newSchedule.last.any((element) =>
                        element['orderUUID'] == order['orderUUID'] &&
                        element['type'] == 'CHECKOUT')) {
                      await newSchedule.last.add({
                        'isStarred': false,
                        'shortDescription': 'Check-out',
                        'description': 'Check-out nhà nghỉ/khách sạn',
                        'type': 'CHECKOUT',
                        'orderUUID': order['orderUUID'],
                        'duration': '00:15:00'
                      });
                    }
                  } else {
                    final index =
                        dateList.last.difference(startDate).inDays + 1;
                    if (!newSchedule[index].any((element) =>
                        element['orderUUID'] == order['orderUUID'] &&
                        element['type'] == 'CHECKOUT')) {
                      await newSchedule[index].add({
                        'isStarred': false,
                        'shortDescription': 'Check-out',
                        'description': 'Check-out nhà nghỉ/khách sạn',
                        'type': 'CHECKOUT',
                        'orderUUID': order['orderUUID'],
                        'duration': '00:15:00'
                      });
                    }
                  }
                }
              }
              for (int index = 0; index < newSchedule.length; index++) {
                for (final item in newSchedule[index]) {
                  if (item['orderUUID'] != null) {
                    final order = tempOrders.firstWhere(
                        (order) => order['orderUUID'] == item['orderUUID']);
                    if (order['type'] == services[1].name) {
                      if (!(index == newSchedule.length - 1) &&
                          !order['serveDateIndexes'].contains(index)) {
                        item['orderUUID'] = null;
                      }
                    } else {
                      if (!order['serveDateIndexes'].contains(index)) {
                        item['orderUUID'] = null;
                      }
                    }
                  }
                }
              }
              order['newTotal'] = null;
              order['newServeDates'] = null;
              order['newDetails'] = null;
              order['newIndexes'] = null;
              order['invalidIndexes'] = null;
            }
            sharedPreferences.setString(
                'plan_schedule', json.encode(newSchedule));
            sharedPreferences.setString(
                'plan_temp_order', json.encode(tempOrders));
            onConfirm();
          },
        ),
      );
    } else {
      sharedPreferences.setString('plan_schedule', json.encode(newSchedule));
      onConfirm();
    }
  }
}
