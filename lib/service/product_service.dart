import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/product.dart';

class ProductService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<ProductViewModel>> getProductsBySupplierId(
      int supplierId, String session) async {
    try {
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

      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          {
            products(
              where: {
                providerId: { eq: $supplierId },
                periods: { some: {in: [$session]} }
                isAvailable: { eq: true }
              },
              order: {
                id: ASC
              }
            ) {
              nodes {
                id
                name
                price
                imagePath
                partySize
                provider {
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

  Future<List<ProductViewModel>> getListProduct(List<int> productIds) async {
    try {
      GraphQLClient newClient = config.getClient();
log(
  '''{
  products(where: { id: { in: $productIds } }) {
    nodes {
      id
      name
      price
      imagePath
      partySize
      provider {
        id
        name
        imagePath
        phone
        address
        type
      }
    }
  }
}'''
);
      final QueryResult result =
          await newClient.query(QueryOptions(document: gql("""
{
  products(first: 50 where: { id: { in: $productIds } }) {
    nodes {
      id
      name
      price
      imagePath
      partySize
      provider {
        id
        name
        imagePath
        phone
        address
        type
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
