import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/register.dart';

class CustomerService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<CustomerViewModel?> GetCustomerByPhone(String phone) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
            query getCustomerByPhone(\$phone: String) {
    travelers
    (
      where: { 
        phone: {eq: \$phone } 
        }
      )
        {
        nodes{
          id
          account{name avatarUrl}
          isMale
          phone
          balance
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

      List? res = result.data!['travelers']['nodes'];
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      List<CustomerViewModel> users =
          res.map((users) => CustomerViewModel.fromJson(users)).toList();
      var rs = users[0];
      return rs;
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
    try {
      QueryResult result = await client.mutate(
          MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql('''
mutation {
  registerTraveler(model: {
    name:"${model.name}"
    birthday:"${model.birthday}"
    isMale:${model.isMale}
    avatarUrl:""
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
      print(client.link);
      if (deviceToken != '') {
        QueryResult result =
            await client.mutate(MutationOptions(document: gql("""
mutation{
    startReceiveNotification(deviceToken: ${json.encode(deviceToken)})
}
""")));
        if (result.hasException) {
          throw Exception(result.exception);
        }
        bool? res = result.data!['startReceiveNotification'];
        if (res == null) {
        return null;
      }
        return res;
      }
      return false;
    } catch (error) {
      throw Exception(error);
    }
  }
}
