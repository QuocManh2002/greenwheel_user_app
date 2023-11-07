import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:intl/intl.dart';

class OrderService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  GraphQLClient client = config.clientToQuery();

  Future<bool> addOrder(OrderCreateViewModel order) async {
    try {
      List<Map<String, dynamic>> details = order.details.map((detail) {
        return {
          'productId': detail.productId,
          'quantity': detail.quantity,
        };
      }).toList();

      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
          mutation PlanOrderCheckoutInput(\$input: PlanOrderCheckoutInput!) {
            planOrderCheckout(input: \$input) {
              result: mutationResult {
                success,
                payload
              }
            }
          }
        '''),
          variables: {
            "input": {
              "vm": {
                "planId": order.planId,
                "pickupDate": DateFormat('yyyy-MM-dd').format(order.pickupDate),
                "returnDate": order.returnDate != null
                    ? DateFormat('yyyy-MM-dd').format(order.returnDate!)
                    : null,
                "note": order.note ?? "",
                "paymentMethod": order.paymentMethod,
                "transactionId": order.transactionId,
                "deposit": order.deposit,
                "details": details,
              },
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      final bool res = result.data?['planOrderCheckout']['result']['success'];
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
