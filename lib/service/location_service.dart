import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/models/tag.dart';
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
          hotline
          provinceId
          emergencyContacts
          templateEvents
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

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  Future<List<LocationViewModel>> searchLocations(
      String search, List<Tag> tags) async {
    try {
      List<String> words = search.split(' ');
      List<String> capitalizedWords =
          words.map((word) => _capitalize(word)).toList();
      String capitalizedSearch = capitalizedWords.join(' ');

      String activities = "";
      String seasons = "";
      String topographic = "";
      String region = "";
      String provinces = "";

      List<Tag> topographicTags = [];
      List<Tag> activitiesTags = [];
      List<Tag> seasonsTags = [];
      List<Tag> provinceTags = [];
      List<Tag> otherTags = [];

      for (Tag tag in tags) {
        switch (tag.type) {
          case 'topographic':
            topographicTags.add(tag);
            break;
          case 'activities':
            activitiesTags.add(tag);
            break;
          case 'seasons':
            seasonsTags.add(tag);
            break;
          case 'province':
            provinceTags.add(tag);
            break;
          default:
            otherTags.add(tag);
            break;
        }
      }

      if (seasonsTags.isNotEmpty) {
        seasons = '''
  seasons: {
    some: {
      in: [${seasonsTags.map((tag) => tag.enumName).join(', ')}]
    }
  }
''';
      }

      if (topographicTags.isNotEmpty) {
        topographic = '''
  topographic: {
    in: [${topographicTags.map((tag) => tag.enumName).join(', ')}]
  }
''';
      }

      if (activitiesTags.isNotEmpty) {
        activities = '''
  activities: {
    some: {
      in: [${activitiesTags.map((tag) => tag.enumName).join(', ')}]
    }
  }
''';
      }

      if (otherTags.isNotEmpty) {
        region = '''
  region: {
    in: [${otherTags.map((tag) => tag.enumName).join(', ')}]
  }
''';
      }

      if (provinceTags.isNotEmpty) {
        provinces = '''
  province: {
        $region
        name: {
            in: [${provinceTags.map((tag) => '"${tag.title}"').join(', ')}]
          }
      }
''';
      }

      print("""
query search(\$search: String!) {
    searchLocations
    (
      first: 100, 
      searchTerm: \$search,
      where: {
        $seasons
        $activities
        $topographic
        $provinces
      }
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
          suggestedTripLength
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
""");

      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query search(\$search: String!) {
    searchLocations
    (
      first: 100, 
      searchTerm: \$search,
      where: {
        $seasons
        $activities
        $topographic
        $provinces
      }
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
          suggestedTripLength
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
"""), variables: {"search": capitalizedSearch}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['searchLocations']['nodes'];
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
      List<ProvinceViewModel> provinces =
          res.map((province) => ProvinceViewModel.fromJson(province)).toList();
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
      suggestedTripLength
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

  Future<LocationViewModel?> GetLocationById(int locationId) async {
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
