import 'dart:convert';
import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_location_model.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_provinces_model.dart';
import 'package:greenwheel_user_app/models/pagination.dart';

abstract class HomeRemoteDataSource {
  Future<Pagination<HomeLocationModel>?> getHotLocations(String? cursor);
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
      final trendingDestinations = getIds.data!['trendingDestinations'];
      if (trendingDestinations == null) {
        return null;
      } else {
        final ids = trendingDestinations['destinations']
            .map((e) => int.parse(e['id'].toString()))
            .toList();

        if (ids.isNotEmpty) {
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
          List<HomeLocationModel> listResult = [];
          for (final id in ids) {
            listResult
                .add(destinations.firstWhere((element) => element.id == id));
          }
          return listResult;
        }
      }
      return [];
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<List<HomeProvinceModel>?> getProvinces() async {
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
  Future<Pagination<HomeLocationModel>?> getHotLocations(String? cursor) async {
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

      log('''
{
  destinations(
    where: { 
      isVisible: { eq: true } 
      seasons:{
        some:{
          in:[$season]
        }
      }
    }
    order: { id: ASC }
    after: ${cursor == null ? null : json.encode(cursor)}
    first: 5
  ){
    pageInfo{
      endCursor
    }
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
''');

      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  destinations(
    where: { 
      isVisible: { eq: true } 
      seasons:{
        some:{
          in:[$season]
        }
      }
    }
    order: { id: ASC }
    after: ${cursor == null ? null : json.encode(cursor)}
    first: 5
  ){
    pageInfo{
      endCursor
    }
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
        return null;
      }
      cursor = result.data!['destinations']['pageInfo']['endCursor'];
      final listObjects =
          res.map((e) => HomeLocationModel.fromJson(e['node'])).toList();
      return Pagination(pageSize: 5, cursor: cursor, objects: listObjects);
      // return listObjects;
    } catch (error) {
      throw Exception(error);
    }
  }
}
