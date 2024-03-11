import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/product.dart';

class ProductService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<ProductViewModel>> getProductsBySupplierId(
      int supplierId, String session) async {
    try {
      // String sessionEnum = "";

      switch (session) {
        case "Buổi sáng":
          session = "MORNING";
          break;
        case "Buổi trưa":
          session = "NOON";
          break;
        case "Buổi chiều":
          session = "AFTERNOON";
          break;
        case "Buổi tối":
          session = "EVENING";
          break;
      }
          // variables: {
          //   "id": supplierId,
          //   "period": [sessionEnum],
          // },

      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          {
            products(
              where: {
                supplierId: { eq: $supplierId },
                periods: { some: {in: [$session]} }
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
                imageUrl
                partySize
                supplier {
                  id
                  name
                }
              }
            }
          }
        '''),
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

  Future<List<ProductViewModel>> getListProduct(List<String> productIds) async {
    try {
      final QueryResult result =
          await client.query(QueryOptions(document: gql("""
{
  products(where: { id: { in: $productIds } }) {
    nodes {
      id
      name
      paymentType
      price
      imageUrl
      partySize
      supplier {
        id
        name
        imageUrl
        phone
        address
      }
    }
  }
}
""")));
      final List? res = result.data?['products']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      } else {
        final List<ProductViewModel> products =
            res.map((product) => ProductViewModel.fromJson(product)).toList();
        return products;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
