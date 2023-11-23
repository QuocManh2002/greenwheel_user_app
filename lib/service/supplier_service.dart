import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';

class SupplierService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  // GraphQLClient client = config.clientToQuery();

  Future<List<SupplierViewModel>> getSuppliers(
      double longitude, double latitude, List<String> types) async {
    try {
      List<Map<String, dynamic>> typeConditions = types.map((type) {
        return {
          'type': {
            'eq': type,
          },
        };
      }).toList();

      String coordinateString = '''
        coordinate: {
          distance: {
            geometry: { type: Point, coordinates: [$longitude, $latitude], crs: 4326 },
            buffer: 0.09138622285234489,
            eq: 0
          }
        },
      ''';
String? userToken = sharedPreferences.getString("userToken");
      final HttpLink httpLink = HttpLink("http://52.76.14.50/graphql");

      final AuthLink authLink =
          AuthLink(getToken: () async => 'Bearer $userToken');

      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          query GetSuppliers(\$typeConditions: [SupplierFilterInput!]) {
            suppliers(
              where: {
                isShow: { eq: false },
                $coordinateString
                or: \$typeConditions
              }
            ) {
              nodes {
                id
                name
                address
                phone
                thumbnailUrl
                coordinate {
                  coordinates
                }
                type
              }
            }
          }
        '''),
          variables: {'typeConditions': typeConditions},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic>? res = result.data?['suppliers']['nodes'];
      if (res == null || res.isEmpty) {
        return <SupplierViewModel>[];
      }

      final List<SupplierViewModel> suppliers =
          res.map((supplier) => SupplierViewModel.fromJson(supplier)).toList();
      return suppliers;
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
