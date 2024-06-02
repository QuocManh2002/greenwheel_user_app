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
  configurations{
    HOLIDAYS{
      name
      from
      to
    }
    MAX_TOPUP
    MIN_TOPUP
    HOLIDAY_RIDING_UP_PCT
    HOLIDAY_LODGING_UP_PCT
    HOLIDAY_MEAL_UP_PCT
    LAST_MODIFIED
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
}
