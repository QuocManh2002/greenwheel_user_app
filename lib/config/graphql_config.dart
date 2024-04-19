import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/main.dart';

class GraphQlConfig {
  String newServer =
      'https://api-btss.southeastasia.cloudapp.azure.com/graphql';

  GraphQLClient getClient() {
    String? userToken = sharedPreferences.getString("userToken");
    print("1: $userToken");
    final HttpLink httpLink = HttpLink(newServer);

    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer $userToken');

    final Link link = authLink.concat(httpLink);

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    return client;
  }
}
