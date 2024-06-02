import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sizer2/sizer2.dart';
import 'package:uuid/uuid.dart';

import '../config/graphql_config.dart';
import '../core/constants/colors.dart';
import '../core/constants/global_constant.dart';
import '../core/constants/service_types.dart';
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
import 'product_service.dart';
import 'supplier_service.dart';

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
      log("""
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
""");
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
      log('''
mutation{
  rateOrder(dto: {
    comment: ${comment == '' ? null : json.encode(comment)}
    orderId:$orderId
    rating:$rating
  }){
    id
  }
}
''');
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
            rs.parsedResponse.errors.first.message.toString(),
            // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['rateOrder']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map?> getOrderByPlan(int planId, String planType) async {
    try {
      String type = '';
      switch (planType) {
        case 'OWN':
          type = 'ownedPlans';
          break;
        case 'JOIN':
          type = 'joinedPlans';
          break;
        case 'PUBLISH':
          type = 'publishedPlans';
      }
      GraphQLClient newClient = await config.getOfflineClient();
      QueryResult result = await newClient.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  $type(where: { id: { eq: $planId } }) {
    nodes {
      actualGcoinBudget
      orders {
        id
        planId
        total
        serveDates
        note
        createdAt
        period
        type
        currentStatus
        uuid
        provider {
          coordinate{
            coordinates
          }
          type
          id
          phone
          name
          imagePath
          address
          isActive
        }
        details {
          id
          price
          quantity
          product {
            id
            partySize
            name
            type
            price
            isAvailable
          }
        }
      }
    }
  }
}
""")));

      if (result.hasException) {
        throw Exception(result.exception!.linkException!);
      }

      List? res = result.data![type]['nodes'][0]['orders'];
      if (res == null) {
        return null;
      }
      List<OrderViewModel>? orders = [];
      for (final item in res) {
        OrderViewModel order = OrderViewModel.fromJson(item);
        if (order.currentStatus != 'CANCELLED') {
          List<OrderDetailViewModel>? details = [];
          for (final detail in item['details']) {
            details.add(OrderDetailViewModel.fromJson(detail));
            order.details = details;
          }
          orders.add(order);
        }
      }
      return {
        'orders': orders,
        'currentBudget': result.data![type]['nodes'][0]['actualGcoinBudget']
      };
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<int?> complainOrder(
      String description, int orderId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  complainOrder(dto: {
    description: "$description"
    orderId:$orderId
  }){
    id
  }
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(),
            // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }
      return result.data!['complainOrder']['id'];
    } catch (error) {
      throw Exception(error);
    }
  }

  updateTempOrder(bool isChangeByMember, int? newMaxMemberCount) async {
    final newMaxMemberCount = sharedPreferences.getInt('plan_number_of_member');
    var orderList =
        json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
    final ProductService productService = ProductService();
    final OrderService orderService = OrderService();
    if (isChangeByMember) {
      for (final order in orderList) {
        if (order['type'] == services[1].name) {
          List<ProductViewModel> products = await productService
              .getProductsBySupplierId(order['providerId'], order['period']);
          final result = orderService.getCheapestDetailCheckinOrder(
              products, newMaxMemberCount!);
          final resultGroupBy = result.groupListsBy((element) => element.id);
          var newDetails = [];
          for (final detail in resultGroupBy.values) {
            newDetails.add({
              'productId': detail.first.id,
              'productName': detail.first.name,
              'quantity': detail.length,
              'partySize': detail.first.partySize,
              'price': detail.first.price.toDouble()
            });
          }
          order['newDetails'] = newDetails;
        } else {
          var newDetails = [];
          for (final detail in order['details']) {
            var newDetail = {
              'productId': detail['productId'],
              'productName': detail['productName'],
              'partySize': detail['partySize'],
              'price': detail['price'].toDouble()
            };
            newDetail['quantity'] =
                (newMaxMemberCount! / detail['partySize']).ceil();
            newDetails.add(newDetail);
          }
          order['newDetails'] = newDetails;
        }
        order['newTotal'] = getTempOrderTotal(order, false);
      }
    } else {
      DateTime startDate =
          DateTime.parse(sharedPreferences.getString('plan_start_date')!);
      for (final order in orderList) {
        List<DateTime> servingDates = [];
        for (final index in order['serveDateIndexes']) {
          servingDates.add(startDate.add(Duration(days: index)));
        }
        order['serveDates'] = order['serveDateIndexes']
            .map((e) =>
                startDate.add(Duration(days: e)).toString().split(' ')[0])
            .toList();
        order['newTotal'] = getTempOrderTotal(order, false);
      }
    }
    sharedPreferences.setString('plan_temp_order', json.encode(orderList));
  }

  updateProductPrice(BuildContext context, bool isUpdatePlan) async {
    var orders =
        json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
    List<double> newPrice = [];
    final SupplierService supplierService = SupplierService();
    final ProductService productService = ProductService();
    List<int> supplierIds = [];
    List<int> productIds = [];
    List<dynamic> invalidOrders = [];
    if (orders.isNotEmpty) {
      for (final order in orders) {
        if (!supplierIds.contains(order['providerId'])) {
          supplierIds.add(order['providerId']);
        }
        for (final detail in order['details']) {
          if (!productIds.contains(detail['productId'])) {
            productIds.add(detail['productId']);
          }
        }
      }
      final invalidSupplierIds =
          await supplierService.getInvalidSupplierByIds(supplierIds, context);

      final invalidProductIds =
          // ignore: use_build_context_synchronously
          await productService.getInvalidProductByIds(productIds, context);
      for (final order in orders) {
        if (invalidSupplierIds.contains(order['providerId'])) {
          order['cancelReason'] = 'Nhà cung cấp không khả dụng';
          invalidOrders.add(order);
        } else if (order['details']
            .any((detail) => invalidProductIds.contains(detail['productId']))) {
          order['cancelReason'] = 'Sản phẩm không khả dụng';
          invalidOrders.add(order);
        }
      }
      if (invalidOrders.isNotEmpty) {
        await AwesomeDialog(
                // ignore: use_build_context_synchronously
                context: context,
                animType: AnimType.leftSlide,
                dialogType: DialogType.infoReverse,
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Thông báo quan trọng',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Các đơn hàng sau đã bị huỷ, hãy tạo lại cho chuyến đi thật đầy đủ nhé',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'NotoSans',
                              color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      for (int index = 0; index < invalidOrders.length; index++)
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? primaryColor.withOpacity(0.1)
                                : lightPrimaryTextColor.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: index == 0
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              topRight: index == 0
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              bottomLeft: index == invalidOrders.length - 1
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              bottomRight: index == invalidOrders.length - 1
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                invalidOrders[index]['type'] == 'EAT'
                                    ? 'Dùng bữa tại:'
                                    : invalidOrders[index]['type'] == 'VISIT'
                                        ? 'Thuê phương tiện:'
                                        : 'Nghỉ ngơi tại:',
                                style: const TextStyle(
                                    fontSize: 13, fontFamily: 'NotoSans'),
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: invalidOrders[index]
                                          ['providerName'],
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: 'NotoSans'),
                                      children: [
                                    TextSpan(
                                        text:
                                            '  (${Utils().getPeriodString(invalidOrders[index]['period'])['text']})',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'NotoSans'))
                                  ])),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.clear_outlined,
                                    color: Colors.red,
                                    weight: 1.5,
                                  ),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      invalidOrders[index]['cancelReason'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                btnOkOnPress: () {
                  var schedule = json
                      .decode(sharedPreferences.getString('plan_schedule')!);
                  for (final order in invalidOrders) {
                    for (final date in schedule) {
                      for (final item in date) {
                        if (item['orderUUID'] == order['orderUUID']) {
                          item['orderUUID'] = null;
                        }
                      }
                    }
                    orders.remove(orders.firstWhere(
                        (e) => e['orderUUID'] == order['orderUUID']));
                    sharedPreferences.setString(
                        'plan_schedule', json.encode(schedule));
                  }
                },
                btnOkColor: Colors.blueAccent,
                btnOkText: 'OK')
            .show();
      } else {}
      productIds.sort();
      final products = await productService.getListProduct(productIds);
      newPrice = products.map((e) => e.price.toDouble()).toList();
      for (final order in orders) {
        for (final detail in order['details']) {
          final index = productIds.indexOf(detail['productId']);
          detail['price'] = newPrice[index];
        }
        order['total'] = getTempOrderTotal(order, false);
      }
    }
    sharedPreferences.setString('plan_temp_order', json.encode(orders));
  }

  getTempOrderTotal(dynamic order, bool isUpdate) {
    final numberHoliday =
        (isUpdate ? order['newServeDates'] : order['serveDates'])
            .where((date) => Utils().isHoliday(DateTime.parse(date)))
            .toList()
            .length;
    final upPct = Utils().getHolidayUpPct(order['type']);
    if (order['newDetails'] != null) {
      return order['newDetails'].fold(
          0,
          (previousValue, element) =>
              previousValue +
              (element['price'] * element['quantity']) *
                  ((1 + upPct / 100) * numberHoliday +
                      ((isUpdate ? order['newServeDates'] : order['serveDates'])
                              .length -
                          numberHoliday)) /
                  GlobalConstant().VND_CONVERT_RATE);
    } else {
      return order['details'].fold(
          0,
          (previousValue, element) =>
              previousValue +
              (element['price'] * element['quantity']) *
                  ((1 + upPct / 100) * numberHoliday +
                      ((isUpdate ? order['newServeDates'] : order['serveDates'])
                              .length -
                          numberHoliday)) /
                  GlobalConstant().VND_CONVERT_RATE);
    }
  }

  List<OrderViewModel> convertFromTempOrder(List<ProductViewModel> products,
      List<dynamic> tempOrders, DateTime startAt) {
    return tempOrders.map((e) {
      List<OrderDetailViewModel> details = [];
      final Map<String, dynamic> cart = e['cart'];
      List<String> serveDates = [];
      double actualTotal = 0;
      ProductViewModel sampleProduct = products.firstWhere(
          (element) => element.id.toString() == cart.entries.first.key);

      for (final index in e["serveDateIndexes"]) {
        serveDates
            .add(startAt.add(Duration(days: index)).toString().split(' ')[0]);
      }
      for (final detail in cart.entries) {
        final product = products
            .firstWhere((element) => element.id.toString() == detail.key);
        details.add(OrderDetailViewModel(
            id: product.id,
            productId: product.id,
            productName: product.name,
            price: product.price.toDouble(),
            isAvailable: product.isAvailable,
            quantity: detail.value));
        actualTotal += product.price * detail.value * serveDates.length / GlobalConstant().VND_CONVERT_RATE;
      }

      return OrderViewModel(
          id: e['id'],
          uuid: e['uuid'],
          details: details,
          note: e['note'],
          serveDates: serveDates,
          total: e['totalGcoin'].toDouble(),
          actualTotal: actualTotal,
          createdAt: DateTime.now(),
          supplier: SupplierViewModel(
              type: sampleProduct.supplierType,
              id: sampleProduct.supplierId!,
              name: sampleProduct.supplierName,
              phone: sampleProduct.supplierPhone,
              thumbnailUrl: sampleProduct.supplierThumbnailUrl,
              isActive: sampleProduct.supplierIsActive,
              address: sampleProduct.supplierAddress),
          type: e['type'],
          period: e['period']);
    }).toList();
  }

  @override
  Iterator get iterator => throw UnimplementedError();
}
