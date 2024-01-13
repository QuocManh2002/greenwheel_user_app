
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/helpers/mapbox_request.dart';

Future <Map> getDirectionsAPIResponse(PointLatLng currentLatLng, PointLatLng destination) async{
  final response = await getDrivingRouteUsingMapbox(currentLatLng, destination);
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];

  Map modifiedResponse = {
    "duration": duration,
    "distance": distance
  };

  return modifiedResponse;
}