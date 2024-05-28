import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlConfig {
  String newServer =
      'https://api-btss.southeastasia.cloudapp.azure.com/graphql';

   GraphQLClient getClient() {
    // final pref = await SharedPreferences.getInstance();
    String? userToken = sharedPreferences.getString("userToken");
    final HttpLink httpLink = HttpLink(newServer);

    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer $userToken');
    log('1 $userToken');
    final Link link = authLink.concat(httpLink);

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    return client;
  }

  Future<GraphQLClient> getOfflineClient() async{
    final pref = await SharedPreferences.getInstance();
    String? userToken = pref.getString("userToken");
    final HttpLink httpLink = HttpLink(newServer);

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
}
