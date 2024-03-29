import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/view_models/topup_viewmodel.dart';

class OrderService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();
//           mutation {
//   createOrder(
//     dto: {
//       details: $details
//       note: ${json.encode(order.note)}
//       period: ${order.period}
//       planId: ${order.planId}
//       servingDates: ${order.servingDates}
//     }
//   ) {
//     id
//   }
// }
  Future<int> addOrder(OrderCreateViewModel order) async {
    try {
      List<Map<String, dynamic>> details = order.details.map((detail) {
        return {
          'key': detail['productId'],
          'value': detail['quantity'],
        };
      }).toList();
      print(details);
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''


mutation{
  createOrder(dto: {
    cart:$details
    note:${json.encode(order.note)}
    period:${order.period}
    planId: ${order.planId}
    serveDateIndexes:${order.servingDates}
  }){
    id
  }
}
          '''),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      final int orderId = result.data?['createOrder']["id"];
      return orderId;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<TopupRequestViewModel?> topUpRequest(int amount) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          mutation {
  createTopUpRequest(dto: {
    amount:$amount
    gateway:VNPAY
  })  {
    transactionId
    paymentUrl
  }
}
          '''),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }
      final int? transactionId =
          result.data?['createTopUpRequest']['transactionId'];
      if (transactionId == null) {
        return null;
      }
      final String paymentUrl =
          result.data?['createTopUpRequest']['paymentUrl'];
      TopupRequestViewModel request = TopupRequestViewModel(
          transactionId: transactionId, paymentUrl: paymentUrl);
      return request;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<TopupViewModel?> topUpSubcription(int transactionId) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          subscription topUp (\$input: Int!) {
  topUpSuccess(transactionId: \$input) {
    id
    status
    gateway
    description
    transactionCode
  }
}
          '''),
          variables: {"input": transactionId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['topUpSuccess'];
      print("RESPONSE: $res");
      if (res == null) {
        return null;
      }

      final int id = result.data?['topUpSuccess']['id'];
      final String status = result.data?['topUpSuccess']['status'];
      final String gateway = result.data?['topUpSuccess']['gateway'];
      final String? description = result.data?['topUpSuccess']['description'];
      final String transactionCode =
          result.data?['topUpSuccess']['transactionCode'];
      TopupViewModel topup = TopupViewModel(
        id: id,
        status: status,
        gateway: gateway,
        description: description,
        transactionCode: transactionCode,
      );
      return topup;
    } catch (error) {
      throw Exception(error);
    }
  }

  List<dynamic> convertTempOrders(List<dynamic> sourceOrders) {
    var orders = [];
    for (final order in sourceOrders) {
      orders.add({
        'providerId': order['providerId'],
        'cart': [
          for (final detail in order['details'])
            {'key': detail['productId'], 'value': detail['quantity']}
        ],
        'note': json.encode(order['note']),
        'period': order['period'],
        'serveDates': order['serveDates'].map((e) => json.encode(e)).toList(),
        'type': order['type']
      });
    }
    return orders;
  }

  Future<int> createOrder(OrderViewModel order, int planId) async {
    try {
      List<Map<String, dynamic>> details = order.details!.map((detail) {
        return {'key': detail.id, 'value': detail.quantity};
      }).toList();

      String mutationText = """
mutation{
  createOrder(dto: {
    cart:$details
    note:"${order.note}"
    period:${order.period}
    planId:$planId
    serveDates:${order.serveDates}
    type:${order.type}
  }){
    id
  }
}
""";

      final QueryResult result = await client.mutate(MutationOptions(
          fetchPolicy: FetchPolicy.noCache, document: gql(mutationText)));
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        var rstext = result.data!;
        int orderId = rstext['createOrder']['id'];
        return orderId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
