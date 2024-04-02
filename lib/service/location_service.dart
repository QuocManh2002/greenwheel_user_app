import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/location_card.dart';
import 'package:greenwheel_user_app/view_models/province.dart';

class LocationService extends Iterable {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();


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

      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query search(\$search: String!) {
    destinations
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
          coordinate{coordinates}
          address
          province{
            id
            name
            imageUrl
          }
          emergencyContacts{
            name
            phone
            address
            type
          }
          comments{
            id
            comment
            createdAt
            account{
              avatarUrl
              name
            }
          }
        }
    }
}
"""), variables: {"search": capitalizedSearch}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['destinations']['nodes'];
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
      destinations : {
        any : true
      }
    }
  ){
    nodes{
      id
      name
      imagePath
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

  Future<List<LocationCardViewModel>> getLocationsByProvinceId(
      int provinceId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  destinations(where: { provinceId: { eq: $provinceId } }) {
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

"""), variables: {"id": provinceId}));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['destinations']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<LocationCardViewModel> locations =
          res.map((location) => LocationCardViewModel.fromJson(location['node'])).toList();
      return locations;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<LocationViewModel?> GetLocationById(int locationId) async {
    try {
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  destinations(where: { id: { eq: $locationId } }) {
    nodes {
      id
      description
      imagePaths
      name
      activities
      seasons
      topographic
      coordinate {
        coordinates
      }
      address
      province {
        id
        name
        imagePath
      }

      comments {
        id
        comment
        createdAt
        account {
          name
        }
      }
    }
  }
}

""")));

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['destinations']['nodes'];
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

  Future<bool> commentOnDestination(
      String commentText, int destinationId) async {
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation {
  commentOnDestination(dto: { comment: "$commentText", destinationId: $destinationId }) {
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      int? res = result.data!['commentOnDestination']['id'];
      if (res == null || res == 0) {
        return false;
      }
      return true;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<CommentViewModel>> getComments(int destinationId) async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql("""
{
  destinations(where: {
    id:{
      eq: $destinationId
    }
  }){
    nodes{
      comments{
        id
        comment
        createdAt
        account{
          id
          name
        }
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['destinations']['nodes'][0]['comments'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<CommentViewModel> comments =
          res.map((comment) => CommentViewModel.fromJson(comment)).toList();
      return comments;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();

  Future<List<LocationCardViewModel>> getLocationCard() async{
    try{
      QueryResult result = await client.query(
        QueryOptions(document: gql("""
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
"""))
      );
      if(result.hasException){
        throw Exception(result.exception);
      }
      List? res = result.data!['destinations']['edges'];
      if(res == null || res.isEmpty){
        return [];
      }
      List<LocationCardViewModel> rs = res.map((e) => LocationCardViewModel.fromJson(e['node'])).toList();
      return rs;
    }catch(error){
      throw Exception(error);
    }
  }
}
