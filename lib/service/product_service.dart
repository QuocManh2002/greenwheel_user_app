import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/product.dart';

class ProductService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<ProductViewModel>> getProductsBySupplierId(
      int supplierId, String session) async {
    try {
      String sessionEnum = "";

      switch (session) {
        case "Buổi sáng":
          sessionEnum = "MORNING";
          break;
        case "Buổi trưa":
          sessionEnum = "NOON";
          break;
        case "Buổi chiều":
          sessionEnum = "AFTERNOON";
          break;
        case "Buổi tối":
          sessionEnum = "EVENING";
          break;
      }

      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          query getSupplierById(\$id: Int!, \$period: [Period!]) {
            products(
              where: {
                supplierId: { eq: \$id },
                periods: { some: {in: \$period} }
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
          variables: {
            "id": supplierId,
            "period": [sessionEnum],
          },
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
