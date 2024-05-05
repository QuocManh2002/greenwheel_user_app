import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/configuration.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/view_models/topup_viewmodel.dart';
import 'package:uuid/uuid.dart';

class OrderService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();

  Future<int> addOrder(OrderCreateViewModel order, BuildContext context) async {
    try {
      List<Map<String, dynamic>> details = order.details.map((detail) {
        return {
          'key': detail['productId'],
          'value': detail['quantity'],
        };
      }).toList();
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
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
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
  createTopUp(dto: {
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
      final int? transactionId = result.data?['createTopUp']['transactionId'];
      if (transactionId == null) {
        return null;
      }
      final String paymentUrl = result.data?['createTopUp']['paymentUrl'];
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

  List<dynamic> convertTempOrders(
      List<dynamic> sourceOrders, DateTime startDate) {
    var orders = [];
    for (final order in sourceOrders) {
      orders.add({
        'uuid': json.encode(order['orderUUID']),
        'cart': [
          for (final detail in order['details'])
            {'key': detail['productId'], 'value': detail['quantity']}
        ],
        'note': json.encode(order['note']),
        'period': order['period'],
        'serveDateIndexes': order['serveDates']
            .map((e) => DateTime.parse(e).difference(startDate).inDays)
            .toList(),
        'type': order['type']
      });
    }
    return orders;
  }

  Future<int> createOrder(
      OrderViewModel order, int planId, BuildContext context) async {
    try {
      List<Map<String, dynamic>> details = order.details!.map((detail) {
        return {'key': detail.id, 'value': detail.quantity};
      }).toList();

      String mutationText = """
mutation{
  createOrder(dto: {
    cart:$details
    note:"${order.note}"
    planId:$planId
    uuid:"${order.uuid}"
  }){
    id
  }
}
""";
      log(mutationText);
      final QueryResult result = await client.mutate(MutationOptions(
          fetchPolicy: FetchPolicy.noCache, document: gql(mutationText)));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);

        throw Exception(result.exception!.linkException!);
      } else {
        var rstext = result.data!;
        int orderId = rstext['createOrder']['id'];
        return orderId;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  List<OrderViewModel> getOrderFromJson(List<dynamic> jsonList) => jsonList
      .map((e) => OrderViewModel(
            createdAt: DateTime.parse(e['createdAt']),
            note: e['note'],
            details: e['details']
                .map((detail) => OrderDetailViewModel(
                    productId: detail['productId'],
                    price: detail['unitPrice'],
                    productName: detail['productName'],
                    unitPrice: detail['unitPrice'],
                    quantity: detail['quantity']))
                .toList(),
            type: e['type'],
            period: e['period'],
            total: double.parse(e['total'].toString()),
            serveDates: e['serveDates'],
            supplier: SupplierViewModel(
                id: e['providerId'],
                name: e['providerName'],
                phone: e['providerPhone'],
                thumbnailUrl: e['providerImageUrl'],
                address: e['providerAddress']),
          ))
      .toList();

  Future<int?> cancelOrder(
      int orderId, BuildContext context, String reason) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation {
  cancelOrder(dto: { orderId: $orderId, reason: "$reason", channel: null }) {
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);
        throw Exception(result.exception!.linkException!);
      }
      return result.data!['cancelOrder']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<OrderViewModel>?> getOrderListByPlanId(
      int planId, BuildContext context) async {
    try {
      QueryResult result = await client.query(QueryOptions(document: gql('''
{
  orders(where: { planId: { eq: $planId } }) {
    edges {
      node {
        id
        planId
        total
        serveDates
        note
        createdAt
        period
        type
        provider {
          type
          id
          phone
          name
          imagePath
          address
        }
        details {
          id
          price
          quantity
          product {
            id
            name
            type
            price
          }
        }
      }
    }
  }
}

''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(), context);
        throw Exception(result.exception!.linkException!);
      }
      List? res = result.data!['orders']['edges'];
      if (res == null || res.isEmpty) {
        return [];
      }
      return res.map((e) => OrderViewModel.fromJson(e['node'])).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  dynamic convertToTempOrder(
          SupplierViewModel supplier,
          String note,
          String type,
          List<Map> details,
          String period,
          List<String> serveDates,
          List<int> serveDateIndexes,
          String? uuid,
          double total) =>
      {
        'orderUUID': uuid ?? const Uuid().v4(),
        'total': total / GlobalConstant().VND_CONVERT_RATE,
        'serveDates': serveDates,
        'period': period,
        'details': details,
        'type': type,
        'note': note.isEmpty ? null : note,
        'providerId': supplier.id,
        'providerStandard': supplier.standard,
        'createdAt': DateTime.now().toString(),
        'providerName': supplier.name,
        'providerPhone': supplier.phone,
        'providerImageUrl': supplier.thumbnailUrl,
        'providerAddress': supplier.address,
        'serveDateIndexes': serveDateIndexes
      };

  bool getAvailableDatesToOrder(int dayIndex, ServiceType serviceType,
      int duration, DateTime arrivedAt, int periodIndex, PlanCreate? plan) {
    if (serviceType.id == 1) {
      if (dayIndex == 0) {
        final session = sessions.firstWhereOrNull((element) =>
            element.from <= arrivedAt.hour && element.to > arrivedAt.hour);
        if (session == null) {
          return true;
        } else {
          if (session.index <= periodIndex) {
            return true;
          } else {
            return false;
          }
        }
      } else if (dayIndex == duration - 1) {
      } else {}
    } else {}
    return true;
  }

  void saveOrderConfigToPref(ConfigurationModel model) {
    sharedPreferences.setStringList('HOLIDAYS',
        (model.HOLIDAYS ?? []).map((e) => json.encode(e.toJson())).toList());
    sharedPreferences.setInt(
        'HOLIDAY_RIDING_UP_PCT', model.HOLIDAY_RIDING_UP_PCT ?? 0);
    sharedPreferences.setInt(
        'HOLIDAY_LODGING_UP_PCT', model.HOLIDAY_LODGING_UP_PCT ?? 0);
    sharedPreferences.setInt(
        'HOLIDAY_MEAL_UP_PCT', model.HOLIDAY_MEAL_UP_PCT ?? 0);
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
