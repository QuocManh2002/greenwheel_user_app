import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';

class DeviceService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<void> startNotification() async{
    try{
      String? deviceToken = sharedPreferences.getString('deviceToken');
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
mutation{
  startReceiveNotification(deviceToken: "$deviceToken")
}
"""))
      );
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        
        return ;
      }
    }catch (error) {
      throw Exception(error);
    }
  }

  Future<void> stopNotification() async{
    try{
      String? deviceToken = sharedPreferences.getString('deviceToken');
    QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
mutation{
  stopReceiveNotification(deviceToken: "$deviceToken")
}
"""))
      );
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        
        return ;
      }
    }catch (error) {
      throw Exception(error);
    }
  }
}