import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/product.dart';

class ProductService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<ProductViewModel>> getProductsBySupplierId(int supplierId) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          query getSupplierById(\$id: Int!) {
            products(
              where: {
                supplierId: { eq: \$id },
                isHidden: { eq: false }
              },
              order: {
                id: ASC
              }
            ) {
              nodes {
                id
                name
                paymentType
                price
                thumbnailUrl
                partySize
                supplier {
                  id
                  name
                }
              }
            }
          }
        '''),
          variables: {"id": supplierId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      final List? res = result.data?['products']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      final List<ProductViewModel> products =
          res.map((product) => ProductViewModel.fromJson(product)).toList();
      return products;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
