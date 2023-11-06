import 'package:collection/collection.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/province.dart';

class LocationService extends Iterable {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  GraphQLClient client = graphQlConfig.clientToQuery();

  Future<List<LocationViewModel>> getLocations() async {
    try {
      QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
    locations
    (
      first: 5, 
      order: { 
        id:ASC
      },
      )
        {
        nodes{
          id
          description
          imageUrls
          name
          activities
          seasons
          topographic
          templatePlan
          coordinate{coordinates}
          address
          lifeguardPhone
          lifeguardAddress
          clinicPhone
          clinicAddress
          hotline
          provinceId
        }
    }
}"""),
      ));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['locations']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }

      List<LocationViewModel> locations =
          res.map((location) => LocationViewModel.fromJson(location)).toList();
      return locations;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<ProvinceViewModel>> getProvinces() async {
    try {
      QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
    locations
    (
      order: { 
        id:ASC
      }, 
      where: {
        
      }
      )
        {
        nodes{
         province{id name thumbnailUrl}
        }
    }
}"""),
      ));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['locations']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<ProvinceViewModel> provinces = res
          .map((province) => ProvinceViewModel.fromJson(province['province']))
          .toList();
      var rs = groupBy(provinces, (ProvinceViewModel p) => p.id);
      List<ProvinceViewModel> newList = [];
      for (final item in rs.keys) {
        newList.add(rs[item]![0]);
      }

      // return provinces.toSet().toList();
      return newList;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<LocationViewModel>> getLocationsByProvinceId(
      int provinceId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query getById(\$id: Int) {
  locations(where: { provinceId: { eq: \$id } }) {
    nodes {
      id
      description
      imageUrls
      name
      activities
      seasons
      topographic
      templatePlan
      coordinate{coordinates}
      address
      lifeguardPhone
      lifeguardAddress
      clinicPhone
      clinicAddress
      hotline
      provinceId
    }
  }
}
"""), variables: {"id": provinceId}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['locations']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<LocationViewModel> locations =
          res.map((location) => LocationViewModel.fromJson(location)).toList();
      return locations;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
