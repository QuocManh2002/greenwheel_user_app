import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/location.dart';

class LocationService {
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
          latitude
          longitude
          address
          lifeguardPhone
          lifeguardAddress
          clinicPhone
          clinicAddress
          hotline
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
}
