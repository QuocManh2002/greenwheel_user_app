import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';

class SupplierService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  GraphQLClient client = config.clientToQuery();

  Future<List<SupplierViewModel>> getSuppliers() async {
    try {
      final QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql('''
        {
          suppliers {
            nodes {
              id
              name
              address
              phone
              thumbnailUrl
              coordinate {
                __typename
                bbox
                coordinates
                crs
                type
              }
            }
          }
        }
      '''),
      ));

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
