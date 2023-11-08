import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/draft.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/finish_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  GraphQLClient client = graphQlConfig.clientToQuery();

  Future<bool> createPlanDraft(PlanDraft draft) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
            mutation CreatePlanDraftInput(\$input: CreatePlanDraftInput!) {
  createPlanDraft(input: \$input) {
    result: mutationResult {
      success
      payload
    }
  }
}
"""), variables: {
        "input": {
          "vm": {
            "startDate":
                "${draft.startDate.year.toString().padLeft(4, '0')}-${draft.startDate.month.toString().padLeft(2, '0')}-${draft.startDate.day.toString().padLeft(2, '0')}",
            "endDate":
                "${draft.endDate.year.toString().padLeft(4, '0')}-${draft.endDate.month.toString().padLeft(2, '0')}-${draft.endDate.day.toString().padLeft(2, '0')}",
            "locationId": draft.locationId,
            "memberLimit": draft.memberLimit
          }
        }
      }));

      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        bool isSuccess = rstext['createPlanDraft']['result']['success'];
        int planId = rstext['createPlanDraft']['result']['payload']['Id'];
        sharedPreferences.setInt("planId", planId);
        return isSuccess;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> finishPlan(PlanFinish finish) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation FinishCreatePlanInput(\$input: FinishCreatePlanInput!) {
  finishCreatePlan(input: \$input) {
    result: mutationResult {
      success
      payload
    }
  }
}
"""), variables: {
        "input": {
          "planId": finish.planId,
          "vm": {
            "startDate":
                "${finish.startDate.year.toString().padLeft(4, '0')}-${finish.startDate.month.toString().padLeft(2, '0')}-${finish.startDate.day.toString().padLeft(2, '0')}",
            "endDate":
                "${finish.endDate.year.toString().padLeft(4, '0')}-${finish.endDate.month.toString().padLeft(2, '0')}-${finish.endDate.day.toString().padLeft(2, '0')}",
            "locationId": finish.locationId,
            "memberLimit": finish.memberLimit,
            "schedule": finish.schedule
          }
        }
      }));

      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        bool isSuccess = rstext['finishCreatePlan']['result']['success'];
        // int planId = rstext['createPlanDraft']['result']['payload']['Id'];
        // sharedPreferences.setInt("planId", planId);
        return isSuccess;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<PlanCardViewModel>> getPlanCard() async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  plans(order: { 
        id:DESC
      },){
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
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
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
}
