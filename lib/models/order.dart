import 'package:phuot_app/models/menu_item_cart.dart';
import 'package:phuot_app/models/service_type.dart';
import 'package:phuot_app/models/supplier.dart';

class Order {
  const Order(
      {required this.total,
      required this.transactionType,
      required this.transactionId,
      required this.note,
      required this.orderDate,
      required this.pickupDate,
      required this.returnDate,
      required this.supplier,
      required this.items,
      required this.rating,
      required this.serviceType});

  final double total;
  final String transactionType;
  final String transactionId;
  final String note;
  final DateTime orderDate;
  final DateTime pickupDate;
  final DateTime? returnDate;
  final Supplier supplier;
  final List<ItemCart> items;
  final double rating;
  final ServiceType serviceType;
}
