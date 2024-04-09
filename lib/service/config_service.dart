import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/models/holiday.dart';

class ConfigService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  Future<List<Holiday>?> getConfig() async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  configurations{
    USE_FIXED_OTP
    MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT
    ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT
    PRODUCT_MAX_PRICE_UP_PCT
    HOLIDAYS{
      name
      from
      to
    }
    LAST_MODIFIED
    DEFAULT_PRESTIGE_POINT
    MIN_TOPUP
    MAX_TOPUP
    BUDGET_ASSURED_PCT
    HOLIDAY_MEAL_UP_PCT
    HOLIDAY_LODGING_UP_PCT
    HOLIDAY_RIDING_UP_PCT
    ORDER_DATE_MIN_DIFF
    ORDER_CANCEL_DATE_DURATION
  }
}
''')));
      if (result.hasException) {
        throw Exception(result.exception!.linkException!);
      }
      List? res = result.data!['configurations']['HOLIDAYS'];
      if (res == null || res.isEmpty) {
        return [];
      }
      return res.map((e) => Holiday.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
