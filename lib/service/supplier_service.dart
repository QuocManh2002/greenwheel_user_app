import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_view.dart';

class SupplierService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<SupplierViewModel>> getSuppliers(
      double longitude, double latitude, List<String> types) async {
    try {
      // List<Map<String, dynamic>> typeConditions = [
      //   {
      //     "type": {
      //       "in": types.map((type) => type).toList(),
      //     },
      //   },
      // ];
      List<Map<String, dynamic>> typeConditions1 = [
        {
          "products": {
            "some": {
              "type": {"in": types.map((type) => type).toList()}
            }
          }
        },
      ];

      print(typeConditions1);

      String coordinateString = '''
        coordinate: {
          distance: {
            geometry: { type: Point, coordinates: [$longitude, $latitude], crs: 4326 },
            buffer: 0.09138622285234489,
            eq: 0
          }
        },
      ''';

      print(coordinateString);
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          query GetSuppliers {
            suppliers(
              where: {
                $coordinateString
                or: $typeConditions1
              }
            ) {
              nodes {
                id
                name
                address
                phone
                imagePath
                coordinate {
                  coordinates
                }
              }
            }
          }
        '''),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic>? res = result.data?['suppliers']['nodes'];
      if (res == null || res.isEmpty) {
        return <SupplierViewModel>[];
      }

      final List<SupplierViewModel> suppliers =
          res.map((supplier) => SupplierViewModel.fromJson(supplier)).toList();
      return suppliers;
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<List<SupplierViewModel>> getSuppliersByIds(List<int> ids) async {
    try {
      final QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
query getSupplierById(\$id: [Int]!) {
            suppliers(
              where: {
                id: { in: \$id },
                isHidden: { eq: false },
              },
              first: 100
              order: {
                id: ASC
              }
            ) {
              nodes {
                id
                name
                address
                phone
                thumbnailUrl
                coordinate {
                  coordinates
                }
                type
              }
            }
          }
"""), variables: {"id": ids}));
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic>? res = result.data?['suppliers']['nodes'];
      if (res == null || res.isEmpty) {
        return <SupplierViewModel>[];
      }

      final List<SupplierViewModel> suppliers =
          res.map((supplier) => SupplierViewModel.fromJson(supplier)).toList();
      return suppliers;
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();

  Future<List<EmergencyContactViewModel>> getEmergencyContacts(
      double longitude, double latitude) async {
    try {
      String coordinateString = '''
        coordinate: {
          distance: {
            geometry: { type: Point, coordinates: [$longitude, $latitude], crs: 4326 },
            buffer: 0.09138622285234489,
            eq: 0
          }
        },
      ''';
      QueryResult result = await client.query(QueryOptions(document: gql("""
{
            suppliers(
              where: {
                $coordinateString
                type:{
      eq:EMERGENCY
    }
              }
            ) {
              nodes {
                id
                name
                address
                phone
                imagePath
              }
            }
          }
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['suppliers']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<EmergencyContactViewModel> rs = res
          .map((e) => EmergencyContactViewModel.fromJsonByLocation(e))
          .toList();
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }
}
