import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/helpers/dio_exception.dart';

Dio _dio = Dio();
String _key = 'Yg51DvrjUjsQBZAcA9YFPrh4CzbLOG0RzSuEoezK';
Future getSearchResult(String searchText) async {
  String url =
      'https://rsapi.goong.io/geocode?address=${searchText}&api_key=${_key}';
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
