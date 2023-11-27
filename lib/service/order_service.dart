import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:intl/intl.dart';

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
          mutation CreateOrder(\$input: CreateOrderModelInput!) {
            createOrder(model: \$input) {
              id
            }
          }
          '''),
          variables: {
            "input": {
              "planId": order.planId,
              "from": DateFormat('yyyy-MM-dd').format(order.pickupDate),
              "to": order.returnDate != null
                  ? DateFormat('yyyy-MM-dd').format(order.returnDate!)
                  : null,
              "note": order.note ?? "",
              "details": details,
            },
          },
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

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
