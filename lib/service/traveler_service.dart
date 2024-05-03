import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/login.dart';
import 'package:greenwheel_user_app/models/register.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/register.dart';

class CustomerService {
  GraphQlConfig graphQlConfig = GraphQlConfig();

  Future<CustomerViewModel?> GetCustomerByPhone(String phone) async {
    GraphQLClient client = graphQlConfig.getClient();
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
{
  accounts(where: { phone: { eq: "$phone" } }) {
    nodes {
      id
      name
      isMale
      gcoinBalance
      phone
      avatarPath
      address
      coordinate{
        coordinates
      }
    }
  }
}
          """),
        ),
      );

      if (result.hasException) {
        if (result.exception!.graphqlErrors.first.extensions!['code']! ==
            "AUTH_NOT_AUTHORIZED") {
          return null;
        } else {
          throw Exception(result.exception);
        }
      }

      List? res = result.data!['accounts']['nodes'];
      if (res == null || res.isEmpty) {
        return null;
      }
      List<CustomerViewModel> users =
          res.map((users) => CustomerViewModel.fromJson(users)).toList();
      return users[0];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addBalance(int balance) async {
    GraphQLClient client = graphQlConfig.getClient();
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  createTopUpRequest(model: {
    amount: $balance
    gateway:STRIPE
  })
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        String transactionId = result.data!['createTopUpRequest'];
        return transactionId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<RegisterModel?> registerTraveler(RegisterViewModel model) async {
    GraphQLClient client = graphQlConfig.getClient();
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql('''
mutation register{
  travelerRegister(dto: {
    deviceToken:"${model.deviceToken}"
    isMale:${model.isMale}
    name:"${model.name}" 
    avatarUrl: ${model.avatarUrl == null ? null : json.encode('$baseBucketImage${model.avatarUrl}')}
  }){
    authResult{
      accessToken
      refreshToken
    }
    account{
      id
      name
      isMale
      gcoinBalance
      phone
      avatarPath
    }
  }
}
''')));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data!['travelerRegister'];
      if (res == null) {
        return null;
      }
      RegisterModel rs = RegisterModel.fromJson(res);
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> travelerSignOut() async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation removeDevice{
  removeDevice{
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final int? rs = result.data!['removeDevice']['id'];
      if (rs == null) {
        return 0;
      } else {
        return rs;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<CustomerViewModel>> GetCustomerById(int id) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
{
    accounts
    (
      where: { 
        id: {eq: $id } 
        }
      )
        {
       nodes {
      id
      name
      isMale
      gcoinBalance
      phone
      avatarPath
    }
    }
}
          """),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['accounts']['nodes'];
      if (res == null || res.isEmpty) {
        return [];
      }
      List<CustomerViewModel> users =
          res.map((users) => CustomerViewModel.fromJson(users)).toList();
      return users;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int?> updateTravelerProfile(CustomerViewModel model) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  travelerUpdate(dto:{
    avatarUrl:${model.avatarUrl == null ? null : json.encode('$baseBucketImage${model.avatarUrl}')}
    address:"${model.defaultAddress}"
    coordinate:[${model.defaultCoordinate!.longitude},${model.defaultCoordinate!.latitude}]
    isMale:${model.isMale}
    name:"${model.name}"
  }){
    id
  }
}
''')));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final int? rs = result.data!['travelerUpdate']['id'];
      if (rs == null) {
        return null;
      } else {
        return rs;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool?> requestTravelerOTP(
      String phoneNumber, BuildContext context) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();

      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation{
  travelerRequestOTP(dto: {
    channel:VONAGE
    phone:"84${phoneNumber.substring(1).toString()}"
  })
}
""")));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['travelerRequestOTP'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<LoginModel?> travelerRequestAuthorize(
      String phoneNumber, String otp) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation auth{
  travelerRequestAuthorize(dto: {
    channel: VONAGE
    phone: "84${phoneNumber.substring(1).toString()}"
    otp: "$otp"
  }){
    accessToken
    refreshToken
    deviceToken
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final rs = result.data!['travelerRequestAuthorize'];
      LoginModel loginModel = LoginModel.fromJson(rs);

      return loginModel;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> getTravelerBalance(int accountId) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(QueryOptions(document: gql("""
{
  accounts(where: {
    id:{
      eq:$accountId
    }
  }){
    edges{
      node{
        gcoinBalance
      }
    }
  }
}
"""), fetchPolicy: FetchPolicy.noCache));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      int? rs = result.data!['accounts']['edges'][0]['node']['gcoinBalance'].toInt();
      if (rs == null) {
        return 0;
      } else {
        return rs;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<LoginModel?> refreshToken(String refreshToken) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation {
  refreshAuth(refreshToken: "$refreshToken") {
    accessToken
    refreshToken
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final rs = result.data!['refreshAuth'];
      LoginModel loginModel = LoginModel.fromJson(rs);

      return loginModel;
    } catch (error) {
      throw Exception(error);
    }
  }

  void saveAccountToSharePref(CustomerViewModel traveler) {
    if (traveler.defaultAddress != null && traveler.defaultCoordinate != null) {
      Utils().SaveDefaultAddressToSharedPref(
          traveler.defaultAddress!, traveler.defaultCoordinate!);
    }
    if (traveler.avatarUrl != null && traveler.avatarUrl!.isNotEmpty) {
      sharedPreferences.setString('userAvatarPath', traveler.avatarUrl!);
    }
    sharedPreferences.setInt('userId', traveler.id);
    sharedPreferences.setBool('userIsMale', traveler.isMale);
    sharedPreferences.setString('userPhone', traveler.phone);
    sharedPreferences.setString('userName', traveler.name);
    sharedPreferences.setInt('userBalance', traveler.balance.toInt());
  }

  Future<int?> setDevice(String deviceToken, BuildContext context) async{
    try{
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(
        MutationOptions(document: gql('''
mutation setDevice{
  setDevice(deviceToken: "$deviceToken"){
    id
  }
}
'''))
      );
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['setDevice']['id'];
    }catch(error){
      throw Exception(error);
    }
  }
}
