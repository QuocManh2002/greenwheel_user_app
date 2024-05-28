import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/graphql_config.dart';
import '../core/constants/sessions.dart';
import '../helpers/util.dart';
import '../main.dart';
import '../models/configuration.dart';
import '../models/service_type.dart';
import '../view_models/order.dart';
import '../view_models/order_create.dart';
import '../view_models/order_detail.dart';
import '../view_models/plan_viewmodels/plan_create.dart';
import '../view_models/product.dart';
import '../view_models/supplier.dart';
import '../view_models/topup_request.dart';
import '../view_models/topup_viewmodel.dart';

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
            rs.parsedResponse.errors.first.message.toString(),
             // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }

      final int orderId = result.data?['createOrder']["id"];
      return orderId;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<TopupRequestViewModel?> topUpRequest(
      int amount, BuildContext context) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
mutation {
  createTopUp(dto: { amount: $amount, gateway: VNPAY }) {
    transaction {
      id
    }
    paymentUrl
  }
}
          '''),
        ),
      );

      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(),
            context);

        throw Exception(result.exception!.linkException!);
      }
      final rs = result.data!['createTopUp'];
      if (rs == null) {
        return null;
      } else {
        return TopupRequestViewModel.fromJson(rs);
      }
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
      List<OrderViewModel> sourceOrders, DateTime startDate) {
    var orders = [];
    for (final order in sourceOrders) {
      orders.add({
        'uuid': json.encode(order.uuid),
        'cart': [
          for (final detail in order.details!)
            {'key': detail.productId, 'value': detail.quantity}
        ],
        'note': json.encode(order.note),
        'period': order.period,
        'serveDateIndexes': order.serveDates!
            .map((e) => DateTime.parse(e).difference(startDate).inDays)
            .toList(),
        'type': order.type
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
      final QueryResult result = await client.mutate(MutationOptions(
          fetchPolicy: FetchPolicy.noCache, document: gql(mutationText)));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(),
            context);

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
            uuid: e['orderUUID'],
            createdAt: DateTime.parse(e['createdAt']),
            note: e['note'],
            details: List<OrderDetailViewModel>.from(e['details'].map(
                (detail) => OrderDetailViewModel(
                    productId: detail['productId'],
                    price: detail['unitPrice'],
                    productName: detail['productName'],
                    quantity: detail['quantity']))).toList(),
            type: e['type'],
            period: e['period'],
            total: double.parse(e['total'].toString()),
            serveDates: List<String>.from(e['serveDates']),
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
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(),
            context);
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
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(),
            context);
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
          String? note,
          String type,
          List<Map> details,
          String period,
          List<String> serveDates,
          List<int> serveDateIndexes,
          String? uuid,
          double total) =>
      {
        'orderUUID': uuid ?? const Uuid().v4(),
        'total': total,
        'serveDates': serveDates,
        'period': period,
        'details': details,
        'type': type,
        'note': note,
        'providerId': supplier.id,
        'providerStandard': supplier.standard,
        'createdAt': DateTime.now().toString(),
        'providerName': supplier.name,
        'providerType': supplier.type,
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
    sharedPreferences.setString(
        'LAST_MODIFIED', model.LAST_MODIFIED.toString());
  }

  List<ProductViewModel> getCheapestDetailCheckinOrder(
      List<ProductViewModel> totalProducts, int numberOfMember) {
    List<List<ProductViewModel>> productList = [];
    List<int> currentCombination = [];
    List<ProductViewModel> result = [];
    double minPrice = 0;
    List<ProductViewModel> sourceProduct = [];
    final productsGroupBy =
        totalProducts.groupListsBy((element) => element.partySize);
    for (final products in productsGroupBy.values) {
      products.sort(
        (a, b) => a.price.compareTo(b.price),
      );
      sourceProduct.add(products.first);
    }
    void backTrack(int startIndex, int currentSum) {
      if (currentSum >= numberOfMember) {
        productList.add(List.from(currentCombination)
            .map((e) =>
                sourceProduct.firstWhere((element) => element.partySize! == e))
            .toList());
        return;
      }
      if (startIndex >= sourceProduct.length) {
        return;
      }
      for (int i = startIndex; i < sourceProduct.length; i++) {
        currentCombination.add(sourceProduct[i].partySize!);
        backTrack(i, currentSum + sourceProduct[i].partySize!);
        currentCombination.removeLast();
      }
    }

    backTrack(0, 0);

    for (var element in productList[0]) {
      minPrice += element.price;
    }
    for (final rooms in productList) {
      double price = 0;
      for (var element in rooms) {
        price += element.price;
      }
      if (price <= minPrice) {
        minPrice = price;
        result = rooms;
      }
    }
    return result;
  }

  Future<int?> rateOrder(
      int orderId, int rating, String comment, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  rateOrder(dto: {
    comment: ${comment == '' ? null : json.encode(comment)}
    orderId:$orderId
    rating:$rating
  }){
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            // ignore: use_build_context_synchronously
            rs.parsedResponse.errors.first.message.toString(),
            context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['rateOrder']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Iterator get iterator => throw UnimplementedError();
}
