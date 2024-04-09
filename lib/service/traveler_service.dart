import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/models/login.dart';
import 'package:greenwheel_user_app/models/register.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/register.dart';

class CustomerService {
  GraphQlConfig graphQlConfig = GraphQlConfig();

  Future<CustomerViewModel?> GetCustomerByPhone(String phone) async {
    //     defaultAddress
    // defaultCoordinate {
    //   coordinates
    // }
    // avatarUrl
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
      print(res);
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
  }){
    authResult{
      accessToken
      refreshToken
    }
    account{
      id
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

  Future<bool?> sendDeviceToken() async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      print(deviceToken);
      if (deviceToken != '') {
        QueryResult result =
            await client.mutate(MutationOptions(document: gql("""
mutation{
    startReceiveNotification(deviceToken: "$deviceToken")
}
""")));
        if (result.hasException) {
          throw Exception(result.exception);
        }
        bool? res = result.data!['startReceiveNotification'];
        if (res == null) {
          return null;
        }
        print("Devicetoken sended!");
        return res;
      }
      return false;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> travelerSignIn(String deviceToken) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
  travelerSignIn(deviceToken: "$deviceToken"){
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final int? rs = result.data!['travelerSignIn']['id'];
      if (rs == null) {
        return 0;
      } else {
        return rs;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int> travelerSignOut() async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation {
  travelerSignOut{
    id
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final int? rs = result.data!['travelerSignOut']['id'];
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
      print(res);
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
  updateTravelerProfile(dto:{
    avatarUrl:"${model.avatarUrl}"
    defaultAddress:"${model.defaultAddress}"
    defaultCoordinate:[${model.defaultCoordinate!.longitude},${model.defaultCoordinate!.latitude}]
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
      final int? rs = result.data!['updateTravelerProfile']['id'];
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
      String phoneNumber, String otp, String deviceToken) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.mutate(MutationOptions(document: gql("""
mutation auth{
  travelerRequestAuthorize(dto: {
    channel: VONAGE
    phone: "84${phoneNumber.substring(1).toString()}"
    otp: "$otp"
    deviceToken: "$deviceToken"
  }){
    accessToken
    refreshToken
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

      int? rs = result.data!['accounts']['edges'][0]['node']['gcoinBalance'];
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
}
