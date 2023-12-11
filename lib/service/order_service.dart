import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/view_models/topup_viewmodel.dart';

class OrderService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<int?> addOrder(OrderCreateViewModel order) async {
    try {
      List<Map<String, dynamic>> details = order.details.map((detail) {
        return {
          'key': detail.productId,
          'value': detail.quantity,
        };
      }).toList();
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          mutation {
  createOrder(
    model: {
      details: $details
      note: ${order.note}
      period: ${order.period}
      planId: ${order.planId}
      servingDates: ${order.servingDates}
    }
  ) {
    id
  }
}
          '''),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      final int? orderId = result.data?['createOrder']["id"];
      if (orderId == null) {
        return null;
      }
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
          mutation createTopUp (\$input: TopUpRequestModelInput!) {
  createTopUpRequest(model: \$input)  {
    transactionId
    paymentUrl
  }
}
          '''),
          variables: {
            "input": {
              "amount": amount,
              "gateway": "VNPAY",
            },
          },
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

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
