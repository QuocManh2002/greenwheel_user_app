import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/helpers/mapbox_reuqest.dart';

Future <Map> getDirectionsAPIResponse(LatLng currentLatLng, LatLng destination) async{
  final response = await getDrivingRouteUsingMapbox(currentLatLng, destination);
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];

  Map modifiedResponse = {
    "duration": duration,
    "distance": distance
  };

  return modifiedResponse;
}