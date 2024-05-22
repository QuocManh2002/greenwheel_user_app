import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';

import '../../models/transaction_type.dart';

List<TransactionType> transactionTypes = [
  TransactionType(
      color: Colors.pinkAccent,
      engName: 'GIFT',
      icon: Icons.monetization_on_outlined,
      index: 0),
  TransactionType(
      color: primaryColor,
      engName: 'ORDER',
      icon: Icons.shopping_cart_checkout_outlined,
      index: 1),
  TransactionType(
      color: Colors.orange,
      engName: 'ORDER_REFUND',
      icon: Icons.remove_shopping_cart_outlined,
      index: 2),
  TransactionType(
      color: Colors.blueAccent,
      engName: 'PLAN_FUND',
      icon: Icons.backpack,
      index: 3),
  TransactionType(
      color: Colors.amber,
      engName: 'PLAN_REFUND',
      icon: Icons.no_backpack_outlined,
      index: 4),
  TransactionType(
      color: Colors.redAccent.withOpacity(0.8),
      engName: 'TOPUP',
      icon: Icons.account_balance,
      index: 5)
];