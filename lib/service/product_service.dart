
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:phuot_app/view_models/product.dart';

import '../helpers/util.dart';

class ProductService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();

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
GraphQLClient client = config.getClient();
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
      final QueryResult result =
          await newClient.query(QueryOptions(document: gql("""
{
  products( where: { id: { in: $productIds } }) {
    nodes {
      id
      name
      price
      imagePath
      partySize
      isAvailable
      provider {
        id
        name
        imagePath
        phone
        address
        type
        isActive
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

  Future<List<ProductViewModel>> getInvalidProductByIds(List<int> ids, BuildContext context)async{
    try{
      GraphQLClient newClient = config.getClient();
      QueryResult result = await newClient.query(QueryOptions(document: gql('''
{
  products(
    where: {
      id:{
        in:$ids
      }
      isAvailable:{
        eq:false
      }
    }
  ){
    edges{
      node{
        id
      name
      price
      imagePath
      partySize
      isAvailable
      provider {
        id
        name
        imagePath
        phone
        address
        type
        isActive
      }
      }
    }
  }
}
''')));
      if(result.hasException){
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      final List? res = result.data?['products']['edges'];
      if(res == null || res.isEmpty){
        return [];
      }else{
        final List<ProductViewModel> products =
            res.map((product) => ProductViewModel.fromJson(product['node'])).toList();
        return products;
      }
    }catch (error) {
      throw Exception(error);
    }
  }

  @override
  Iterator get iterator => throw UnimplementedError();
}
