import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/helpers/dio_exception.dart';

Dio _dio = Dio();
String accessToken = "pk.eyJ1IjoicXVvY21hbmgyMDIiLCJhIjoiY2xuNGdremoxMDA5czJ1cW11bDlnbnVuNyJ9.tVbjQ8dn3-ShbqqKjEsFWQ";
Future getDrivingRouteUsingMapbox(LatLng source, LatLng destination) async{
  String url = '$baseMaxboxDirectionUrl${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?alternatives=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$accessToken';
  try{
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    return responseData.data;
  }catch(e){
    final errorMessage = DioExceptions.fromDioError(e as DioException).toString();
    debugPrint(errorMessage);
  }
}