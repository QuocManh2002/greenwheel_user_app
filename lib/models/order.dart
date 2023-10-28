import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/supplier.dart';

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
      required this.items});

  final double total;
  final String transactionType;
  final int transactionId;
  final String note;
  final DateTime orderDate;
  final DateTime pickupDate;
  final DateTime returnDate;
  final Supplier supplier;
  final List<ItemCart> items;
}
