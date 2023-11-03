import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQlConfig{
  static HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");
  GraphQLClient clientToQuery() => GraphQLClient(link: httpLink, cache: GraphQLCache(store: HiveStore()));
}