import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlConfig {
  String server = 'https://api-btss.southeastasia.cloudapp.azure.com/graphql';

  static final WebSocketLink webSocketLink = WebSocketLink(
      'https://api-btss.southeastasia.cloudapp.azure.com/graphql',
      config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: const Duration(minutes: 30),
          initialPayload: {
            'headers': {
              'Authorization':
                  'Bearer ${sharedPreferences.getString("userToken")}'
            }
          }));

  GraphQLClient getClient() {
    String? userToken = sharedPreferences.getString("userToken");
    final HttpLink httpLink = HttpLink(server);

    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer $userToken');
    log('1 $userToken');
    final Link link = authLink.concat(httpLink);
    // final Link link = authLink.split(
    //   (request) => request.isSubscription,
    //   // webSocketLink,
    //   httpLink,
    // );

    GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
        alwaysRebroadcast: true,
        defaultPolicies: DefaultPolicies(
          watchQuery: Policies(fetch: FetchPolicy.noCache),
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
          subscribe: Policies(fetch: FetchPolicy.noCache),
        ));

    return client;
  }

  Future<GraphQLClient> getOfflineClient() async {
    final pref = await SharedPreferences.getInstance();
    String? userToken = pref.getString("userToken");
    final HttpLink httpLink = HttpLink(server);

    log('2 $userToken');

    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer $userToken');

    final Link link = authLink.concat(httpLink);

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    return client;
  }

  Link getGqlServerLink() {
    String? userToken = sharedPreferences.getString("userToken");
    final HttpLink httpLink = HttpLink(server);

    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer $userToken');
    return authLink.concat(httpLink);
  }
}
