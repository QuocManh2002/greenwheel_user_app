import 'package:greenwheel_user_app/models/menu_item.dart';
import 'package:greenwheel_user_app/models/supplier.dart';

class Cart {
  const Cart(
      {required this.total,
      required this.transactionType,
      required this.transactionId,
      required this.note,
      required this.receiveDate,
      required this.returnDate,
      required this.supplier,
      required this.items});

  final double total;
  final String transactionType;
  final int transactionId;
  final String note;
  final DateTime receiveDate;
  final DateTime returnDate;
  final Supplier supplier;
  final List<MenuItem> items;
}
