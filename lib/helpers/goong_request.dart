// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:phuot_app/core/constants/global_constant.dart';
import 'package:phuot_app/core/errors/dio_exception.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

Dio _dio = Dio();
String _key = dotenv.env['goong_api_key'].toString();
Future getSearchResult(String searchText) async {
  String url =
      '${GlobalConstant().baseGoongUrl}geocode?address=$searchText&api_key=$_key';
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

Future getRouteInfo(PointLatLng source, PointLatLng destination) async {
  String url =
      '${GlobalConstant().baseGoongUrl}Direction?origin=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&vehicle=car&api_key=$_key';
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

Future getPlaceDetail(PointLatLng place) async {
  String url =
      '${GlobalConstant().baseGoongUrl}Geocode?latlng=${place.latitude},${place.longitude}&api_key=${_key}';
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
