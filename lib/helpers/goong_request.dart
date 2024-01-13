import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/helpers/dio_exception.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

Dio _dio = Dio();
String _key = 'Yg51DvrjUjsQBZAcA9YFPrh4CzbLOG0RzSuEoezK';
Future getSearchResult(String searchText) async {
  String url =
      '${baseGoongUrl}geocode?address=$searchText&api_key=$_key';
  try {
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    return responseData.data;
  } catch (e) {
    final errorMessage =
        DioExceptions.fromDioError(e as DioException).toString();
    debugPrint(errorMessage);
  }
}

Future getRouteInfo(PointLatLng source, PointLatLng destination) async{
  String url = '${baseGoongUrl}Direction?origin=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&vehicle=car&api_key=$_key';
  try{
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    return responseData.data;
  }catch(e){
    final errorMessage = DioExceptions.fromDioError(e as DioException).toString();
    debugPrint(errorMessage);
  }
}
