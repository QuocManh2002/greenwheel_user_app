import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/register.dart';

class CustomerService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<List<CustomerViewModel>> GetCustomerByPhone(String phone) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
            query getCustomerByPhone(\$phone: String) {
    accounts
    (
      where: { 
        phone: {eq: \$phone } 
        }
      )
        {
        nodes {
      id
      defaultAddress
      defaultCoordinate {
        coordinates
      }
      name
      avatarUrl
      isMale
      gcoinBalance
      phone
    }
    }
}
          """),
          variables: {"phone": phone},
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

  Future<String?> addBalance(int balance) async {
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

  Future<int?> registerTraveler(RegisterViewModel model) async {
    print(sharedPreferences.getString('userToken'));
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql('''
mutation {
  registerTraveler(dto: {
     deviceToken:${json.encode(model.deviceToken)}
     isMale: ${model.isMale}
     name:${json.encode(model.name)}
  }){
    id
  }
}
''')));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      int? res = result.data!['registerTraveler']['id'];
      if (res == null) {
        return null;
      }
      TokenRefresher.refreshToken();
      // sendDeviceToken();
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool?> sendDeviceToken() async {
    try {
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
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
mutation{
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
}
