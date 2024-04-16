import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/view_models/topup_viewmodel.dart';

class OrderService extends Iterable {
  static GraphQlConfig config = GraphQlConfig();
  static GraphQLClient client = config.getClient();
  final ProductService _productService = ProductService();

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

  List<dynamic> convertTempOrders(List<dynamic> sourceOrders) {
    var orders = [];
    for (final order in sourceOrders) {
      orders.add({
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
    period:${order.period}
    planId:$planId
    serveDates:${order.serveDates}
    type:${order.type}
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
          int total) =>
      {
        'total': total,
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
        'providerAddress': supplier.address
      };

  Future<List<OrderViewModel>?> getTempOrderFromSchedule(
      List<dynamic> schedule, DateTime startDate) async {
    List<dynamic> orderList = [];
    List<int> ids = [];
    int i = 0;
    for (final day in schedule) {
      for (final activity in day) {
        if (activity['tempOrder'] != null) {
          final orderKey =
              '${activity['tempOrder']['cart']} ${activity['tempOrder']['period']}';

          if (!orderList.any((element) =>
              '${element['order']['cart']} ${element['order']['period']}' ==
              orderKey)) {
            orderList.add({
              'order': activity['tempOrder'],
              'serveDates': [i]
            });
          } else {
            final temp = orderList.firstWhere((element) =>
                '${element['order']['cart']} ${element['order']['period']}' ==
                orderKey)['serveDates'];

            orderList.firstWhere((element) =>
                '${element['order']['cart']} ${element['order']['period']}' ==
                orderKey)['serveDates'] = [...temp, i];
          }
        }
      }
      i++;
    }
    for (final order in orderList) {
      if (order['order']['cart'].runtimeType == List<dynamic>) {
        for (final id in order['order']['cart']) {
          if (!ids.contains(int.parse(id['key'].toString()))) {
            ids.add(int.parse(id['key'].toString()));
          }
        }
      } else {
        for (final id in order['order']['cart'].keys.toList()) {
          if (!ids.contains(id)) {
            ids.add(int.parse(id));
          }
        }
      }
    }
    List<ProductViewModel>? products =
        await _productService.getListProduct(ids);

    return orderList.map((order) {
      ProductViewModel sampleProduct = products.firstWhere((element) =>
          element.id.toString() ==
          (order['order']['cart'].runtimeType == List
              ? order['order']['cart'].first['key'].toString()
              : order['order']['cart'].entries.first.key));
      return OrderViewModel(
          details: (order['order']['cart'].runtimeType == List
                  ? order['order']['cart']
                  : order['order']['cart'].entries)
              .map((detail) {
            final product = products.firstWhere((element) =>
                element.id.toString() ==
                (detail.runtimeType.toString() == '_Map<String, dynamic>'
                    ? detail['key'].toString()
                    : detail.key));
            return OrderDetailViewModel(
                id: product.id,
                productId: product.id,
                productName: product.name,
                price: product.price.toDouble(),
                unitPrice: product.price.toDouble(),
                quantity:
                    detail.runtimeType.toString() == '_Map<String, dynamic>'
                        ? detail['value']
                        : detail.value);
          }).toList(),
          note: order['note'],
          serveDates: order["serveDates"]
              .map((day) =>
                  startDate.add(Duration(days: day)).toString().split(' ')[0])
              .toList(),
          total: order['order']['total'].toDouble(),
          createdAt: DateTime.now(),
          supplier: SupplierViewModel(
              type: sampleProduct.supplierType,
              id: sampleProduct.supplierId!,
              name: sampleProduct.supplierName,
              phone: sampleProduct.supplierPhone,
              thumbnailUrl: sampleProduct.supplierThumbnailUrl,
              address: sampleProduct.supplierAddress),
          type: getOrdeType(sampleProduct.supplierType!),
          period: order['order']['period']);
    }).toList();
  }

  getOrdeType(String supplierType) {
    switch (supplierType) {
      case "FOOD_STALL":
        return "EAT";
      case "RESTAURANT":
        return "EAT";
      case "HOTEL":
        return "CHECKIN";
      case "MOTEL":
        return "CHECKIN";
      case "VEHICLE_RENTAL":
        return 'VISIT';
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}
