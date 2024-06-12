import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/models/configuration.dart';

class ConfigService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  
  Future<ConfigurationModel?> getConfig(BuildContext context) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  configurations {
    USE_FIXED_OTP
    ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT
    HOLIDAYS {
      name
      from
      to
    }
    LAST_MODIFIED
    DEFAULT_PRESTIGE_POINT
    MIN_TOPUP
    MAX_TOPUP
    HOLIDAY_MEAL_UP_PCT
    HOLIDAY_LODGING_UP_PCT
    HOLIDAY_RIDING_UP_PCT
    ORDER_PROCESSING_DATE_DURATION
    MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT
    ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT

    BUDGET_ASSURANCE_RATE
    PLAN_COMPLETE_AFTER_DAYS
    ORDER_COMPLETE_AFTER_DAYS
    MIN_PLAN_MEMBER
    MAX_PLAN_MEMBER
    MIN_DEPART_DIFF
    MAX_DEPART_DIFF
    MIN_PERIOD
    MAX_PERIOD
  }
}

''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      final res = result.data!['configurations'];
      if (res == null) {
        return null;
      }
      return ConfigurationModel.fromJson(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> getAdditionalSpan(BuildContext context) async{
    try{
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(
        QueryOptions(document: gql('''
{
  additionalSpan
}
'''))
      );
      if(result.hasException){
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data?['additionalSpan'];
    }catch (error) {
      throw Exception(error);
    }
  }
}
