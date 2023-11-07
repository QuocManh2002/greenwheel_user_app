import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
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
            "startDate": draft.startDate,
            "endDate": draft.endDate,
            "locationId": draft.locationId,
            "memberLimit": draft.memberLimit
          }
        }
      }));

      if(result.hasException){
        throw Exception(result.exception);
      }else{
        return true;
      }

    } catch (error) {
      throw Exception(error);
    }
  }
}
