

import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/plan_item.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/draft.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/finish_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<bool> createPlanDraft(PlanDraft draft) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  createDraftPlan(model: {
    memberLimit: ${draft.memberLimit}
    endDate: "${draft.endDate.year.toString().padLeft(4, '0')}-${draft.endDate.month.toString().padLeft(2, '0')}-${draft.endDate.day.toString().padLeft(2, '0')}"
    startDate: "${draft.startDate.year.toString().padLeft(4, '0')}-${draft.startDate.month.toString().padLeft(2, '0')}-${draft.startDate.day.toString().padLeft(2, '0')}"
    locationId: ${draft.locationId}
    schedule : ${draft.schedule}
  }){
    id
    status
  }
}
"""), ));

      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        // bool isSuccess = rstext['createPlanDraft']['result']['success'];
        int planId = rstext['createDraftPlan']['id'];
        sharedPreferences.setInt("planId", planId);
        return true;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> finishPlan(PlanFinish finish) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation {
  updatePlan(model: {
    memberLimit: ${finish.memberLimit}
    endDate: "${finish.endDate.year.toString().padLeft(4, '0')}-${finish.endDate.month.toString().padLeft(2, '0')}-${finish.endDate.day.toString().padLeft(2, '0')}"
    startDate: "${finish.startDate.year.toString().padLeft(4, '0')}-${finish.startDate.month.toString().padLeft(2, '0')}-${finish.startDate.day.toString().padLeft(2, '0')}"
    isOpenToJoin: true
    planId: ${finish.planId}
    schedule: ${finish.schedule}
  }) {
    id
    locationId
  }
}
"""), 
      ));

      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        int planId = result.data!['updatePlan']['id'];
        return planId;
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
    (where: {status:{eq:${status}}} order: {id:DESC})
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

  Future<List<OrderCreatePlan>> getOrderCreatePlan(int planId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(
            fetchPolicy: FetchPolicy.noCache, 
            document: gql("""
query getOrderDetailsByPlanId(\$planId: Int) {
  orders(where: { planId: { eq: \$planId } }) {
    nodes {
      id
      planId
      deposit
      details {
        price
        quantity
        product {
          name
          supplier {
            thumbnailUrl
            name
            type
          }
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

      List<OrderCreatePlan> orders =
          res.map((order) => OrderCreatePlan.fromJson(order)).toList();
      return orders;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<PlanDetail?> GetPlanById(int planId) async{
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query GetPlanById(\$planId: Int){
  plans(where: {id: {eq: \$planId}}){
    nodes{
      id
      startDate
      endDate
      schedule
      memberLimit
      status
      orders{
        id
        travelerId
        note
        deposit
        servingDates
        total
        details{
          id
          quantity
          price
          product{
            name
            supplier{
              type
              name
              thumbnailUrl
            }
            }
            }
            }
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
      List<PlanDetail> plan = res.map((plan) => PlanDetail.fromJson(plan)).toList();
      var rs = plan[0];
      // rs.orders = res[0]["orders"];
      // List<OrderViewModel>? orders = res[0]["orders"].map((order) => OrderViewModel.fromJson(order)).toList();
      List<OrderViewModel>? orders = [];
      for(final item in res[0]["orders"]){
        List<OrderDetailViewModel>? details = [];
        OrderViewModel order = OrderViewModel.fromJson(item);
        for(final detail in item["details"]){
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
  plans(first: 20){
    nodes{
      id
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

  List<List<String>> GetPlanDetailFormJson(List<dynamic> details){
    List<List<String>> schedule = [];
    for(final detail in details){
      List<String> items = [];
      for(final item in detail){
        items.add(json.encode(item));
      }
      schedule.add(items);
    }
    return schedule;
  }

  List<List<String>> GetPlanDetailFromListPlanItem(List<PlanItem> planDetail){
    List<List<String>> schedule = [];
    for(final detail in planDetail){
      List<String> items = [];
      for(final item in detail.details){
        items.add(json.encode(item));
      }
      schedule.add(items);
    }
    return schedule;
  }

  Future<int?> joinPlan(int planId) async{
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
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
}
