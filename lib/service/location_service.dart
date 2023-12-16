
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/province.dart';

class LocationService extends Iterable {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<List<LocationViewModel>> getLocations() async {
    try {
      QueryResult result = await client.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
    locations
    (
      first: 10, 
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
          templateSchedule
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

"""),
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
  provinces(
    where: {
      locations : {
        any : true
      }
    }
  ){
    nodes{
      id
      name
      thumbnailUrl
    }
  }
}
"""),
      ));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['provinces']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<ProvinceViewModel> provinces = res.map((province) => ProvinceViewModel.fromJson(province)).toList();
      return provinces;
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
      templateSchedule
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

  Future<LocationViewModel?> GetLocationById(int locationId) async{
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query getByLocationId(\$id: Int) {
  locations(where: { id: { eq: \$id } }) {
    nodes {
      id
      description
      imageUrls
      name
      activities
      seasons
      topographic
      templateSchedule
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
"""), variables: {"id": locationId}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['locations']['nodes'];
      if (res == null || res.isEmpty) {
        return null;
      }
      List<LocationViewModel> locations =
          res.map((location) => LocationViewModel.fromJson(location)).toList();
      return locations[0];
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
