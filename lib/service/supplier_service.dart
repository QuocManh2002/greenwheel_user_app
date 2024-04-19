import 'dart:developer';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';

class SupplierService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<List<SupplierViewModel>> getSuppliers(
      PointLatLng coordinate, List<String> types, Session? session) async {
    try {
      log('''
{
  providers(
    where: {
      and: [
        {
          coordinate: {
            distance: {
              lte: 10000
              geometry: {
                type: Point
                coordinates: [${coordinate.longitude}, ${coordinate.latitude}]
              }
            }
          }
        }
        {
          products: {
            some: {
              and: [
                { type: { eq: ${types.first} } }
                { periods: { some: { in: ${session!.enumName} } } }
              ]
            }
          }
        }
      ]
    }
  ) {
    edges {
      node {
        id
        name
        address
        phone
        imagePath
        standard
        products{
          id
          name
          periods
          type
        }
        coordinate{
                coordinates
              }
      }
    }
  }
}
''');
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
{
  providers(
    where: {
      and: [
        {
          coordinate: {
            distance: {
              lte: 10000
              geometry: {
                type: Point
                coordinates: [${coordinate.longitude}, ${coordinate.latitude}]
              }
            }
          }
        }
        {
          products: {
            some: {
              and: [
                { type: { eq: ${types.first} } }
                { periods: { some: { in: ${session.enumName} } } }
              ]
            }
          }
        }
      ]
    }
  ) {
    edges {
      node {
        id
        name
        address
        phone
        imagePath
        standard
        products{
          id
          name
          periods
          type
        }
        coordinate{
                coordinates
              }
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

      final List<dynamic>? res = result.data?['providers']['edges'];
      if (res == null || res.isEmpty) {
        return <SupplierViewModel>[];
      }

      final List<SupplierViewModel> suppliers = res
          .map((supplier) => SupplierViewModel.fromJson(supplier['node']))
          .toList();
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

  Future<List<EmergencyContactViewModel>?> getEmergencyContacts(
      PointLatLng coordinate, List<String> types, int lte) async {
    try {
      GraphQLClient newClient = config.getClient();

      log('''
{
  providers(
    where: {
      and: [
        {
          coordinate: {
            distance: {
              lte: $lte
              geometry: { type: Point, coordinates: [${coordinate.longitude}, ${coordinate.latitude}] }
            }
          }
        }
        { type: { in: $types } }
      ]
    }
  ) {
    nodes {
      id
      name
      address
      phone
      imagePath
      type
    }
  }
}''');
      QueryResult result = await newClient.query(QueryOptions(document: gql("""
{
  providers(
    where: {
      and: [
        {
          coordinate: {
            distance: {
              lte: $lte
              geometry: { type: Point, coordinates: [${coordinate.longitude}, ${coordinate.latitude}] }
            }
          }
        }
        { type: { in: $types } }
        { isActive: { eq: true } }
      ]
    }
  ) {
    nodes {
      id
      name
      address
      phone
      imagePath
      type
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['providers']['nodes'];
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
