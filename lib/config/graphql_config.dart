import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/main.dart';

class GraphQlConfig {
  // static HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");
  // GraphQLClient clientToQuery() =>
  //     GraphQLClient(link: httpLink, cache: GraphQLCache(store: HiveStore()));

  static HttpLink httpLink =
      HttpLink("https://greenwheels.southeastasia.cloudapp.azure.com/graphql");

  // Add the AuthLink to the link chain if userToken is not null
  static Link linkWithAuth(String? userToken) {
    if (userToken != null && userToken.isNotEmpty) {
      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');
      return authLink.concat(httpLink);
    } else {
      return httpLink;
    }
  }

  GraphQLClient clientToQuery(String? userToken) => GraphQLClient(
        cache: GraphQLCache(),
        link: linkWithAuth(userToken),
      );

  GraphQLClient getClient() {
    String? userToken = sharedPreferences.getString("userToken");
    print("1: $userToken");
    final HttpLink httpLink = HttpLink(
        "https://greenwheels.azurewebsites.net/graphql");

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
