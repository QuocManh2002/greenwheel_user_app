import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/models/holiday.dart';

class ConfigService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  Future<List<Holiday>?> getConfig() async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  configurations{
    HOLIDAYS{
      name
      from
      to
    }
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
