import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/draft.dart';

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
            "startDate": "${draft.startDate.year.toString().padLeft(4, '0')}-${draft.startDate.month.toString().padLeft(2, '0')}-${draft.startDate.day.toString().padLeft(2, '0')}",
            "endDate": "${draft.endDate.year.toString().padLeft(4, '0')}-${draft.endDate.month.toString().padLeft(2, '0')}-${draft.endDate.day.toString().padLeft(2, '0')}",
            "locationId": draft.locationId,
            "memberLimit": draft.memberLimit
          }
        }
      }));

      if(result.hasException){
        throw Exception(result.exception);
      }else{
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
}
