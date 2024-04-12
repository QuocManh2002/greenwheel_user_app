import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_location_model.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_provinces_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeLocationModel>?> getLocations();
  Future<List<HomeProvinceModel>?> getProvinces();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  HomeRemoteDataSourceImpl();

  @override
  Future<List<HomeLocationModel>?> getLocations() async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql("""
{
  destinations(where: {
    isVisible:{
      eq:true
    }
  }){
    edges{
      node{
        id
        description
        name
        imagePaths
        rating
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['destinations']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<HomeLocationModel> rs =
          res.map((e) => HomeLocationModel.fromJson(e['node'])).toList();
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<List<HomeProvinceModel>?> getProvinces() async {
    // TODO: implement getProvinces
    try {
      QueryResult result = await client.query(QueryOptions(document: gql("""
{
  provinces(where: { destinations: { any: true } }) {
    edges {
      node {
        id
        name
        imagePath
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['provinces']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<HomeProvinceModel> rs =
          res.map((e) => HomeProvinceModel.fromJson(e['node'])).toList();
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }
}
