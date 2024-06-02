import 'dart:developer';

import 'package:phuot_app/main.dart';
import 'package:phuot_app/models/login.dart';
import 'package:phuot_app/service/traveler_service.dart';

class TokenRefresher {
  static final CustomerService _customerService = CustomerService();

  static Future<void> refreshToken() async {
    String? refreshToken = sharedPreferences.getString('userRefreshToken');
    log('refresh: $refreshToken');
     LoginModel? loginModel = await _customerService.refreshToken(refreshToken!);
    if(loginModel != null){
      log(loginModel.accessToken);
      sharedPreferences.setString('userToken', loginModel.accessToken);
      sharedPreferences.setString('userRefreshToken', loginModel.refreshToken);
    }
  }
}
