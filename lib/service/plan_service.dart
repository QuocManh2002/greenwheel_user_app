

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/draft.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/finish_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';

class PlanService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  // GraphQLClient client = graphQlConfig.clientToQuery();

  Future<bool> createPlanDraft(PlanDraft draft) async {
    try {
      String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  createDraftPlan(model: {
    locationId: ${draft.locationId}
    endDate: "${draft.endDate.year.toString().padLeft(4, '0')}-${draft.endDate.month.toString().padLeft(2, '0')}-${draft.endDate.day.toString().padLeft(2, '0')}"
    memberLimit: ${draft.memberLimit}
    startDate:"${draft.startDate.year.toString().padLeft(4, '0')}-${draft.startDate.month.toString().padLeft(2, '0')}-${draft.startDate.day.toString().padLeft(2, '0')}"
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
      String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation {
  updatePlan(model: {
    memberLimit: ${finish.memberLimit}
    endDate: "${finish.endDate.year.toString().padLeft(4, '0')}-${finish.endDate.month.toString().padLeft(2, '0')}-${finish.endDate.day.toString().padLeft(2, '0')}"
    startDate: "${finish.startDate.year.toString().padLeft(4, '0')}-${finish.startDate.month.toString().padLeft(2, '0')}-${finish.startDate.day.toString().padLeft(2, '0')}"
    isOpenToJoin: true
    planId: ${finish.planId}
    schedule : {
    activities:
      ${finish.schedule}
  }
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
      String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
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
      String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
      QueryResult result = await client.query(
          QueryOptions(
            fetchPolicy: FetchPolicy.noCache, 
            document: gql("""
query getOrderDetailsByPlanId(\$planId: Int) {
  orders(where: { planId: { eq: \$planId } }) {
    nodes {
      id
      planId
      transaction{
        amount
      }
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
      String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
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
        note
        transactionId 
        transaction{
          amount
        }
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
      isOpenToJoin
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
}
