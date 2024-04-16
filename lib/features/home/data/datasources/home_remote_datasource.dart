import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_location_model.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_provinces_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeLocationModel>?> getHotLocations();
  Future<List<HomeLocationModel>?> getTrendingLocations();
  Future<List<HomeProvinceModel>?> getProvinces();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();
  HomeRemoteDataSourceImpl();

  @override
  Future<List<HomeLocationModel>?> getTrendingLocations() async {
    try {
      QueryResult getIds = await client.query(QueryOptions(document: gql('''
{
  trendingDestinations{
    destinations{
      id
    }
  }
}
''')));
      if (getIds.hasException) {
        throw Exception(getIds.exception);
      }
      List? ids = getIds.data!['trendingDestinations']['destinations']
          .map((e) => e['id'])
          .toList();
      if (ids != null) {
        QueryResult result = await client.query(QueryOptions(document: gql("""
{
  destinations(where: {
    isVisible:{
      eq:true
    }
    id:{in:$ids}
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
        List<HomeLocationModel> destinations =
            res.map((e) => HomeLocationModel.fromJson(e['node'])).toList();

        return ids
            .map((e) => destinations.firstWhere((element) => element.id == e))
            .toList();
      }
      return [];
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

  @override
  Future<List<HomeLocationModel>?> getHotLocations() async {
    try {
      String? season;
      final today = DateTime(0, DateTime.now().month, DateTime.now().day);
      if (today.isAfter(DateTime(0, 1, 1)) &&
          today.isBefore(DateTime(0, 4, 1))) {
        season = 'SPRING';
      } else if (today.isAfter(DateTime(0, 3, 31)) &&
          today.isBefore(DateTime(0, 7, 1))) {
        season = 'SUMMER';
      } else if (today.isAfter(DateTime(0, 31, 6)) &&
          today.isBefore(DateTime(0, 10, 1))) {
        season = 'FALL';
      } else {
        season = 'WINTER';
      }

      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  destinations(
    where: {
      seasons:{
        some:{
          in:[$season]
        }
      }
    }
  ){
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
''')));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['destinations']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }
      return res.map((e) => HomeLocationModel.fromJson(e['node'])).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
