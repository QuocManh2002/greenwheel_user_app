import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/models/configuration.dart';

class ConfigService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  Future<ConfigurationModel?> getOrderConfig() async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  configurations{
    HOLIDAYS{
      name
      from
      to
    }
    HOLIDAY_RIDING_UP_PCT
    HOLIDAY_LODGING_UP_PCT
    HOLIDAY_MEAL_UP_PCT
  }
}
''')));
      if (result.hasException) {
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
