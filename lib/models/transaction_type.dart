import 'package:flutter/material.dart';

class TransactionType {
  final int index;
  final IconData icon;
  final String engName;
  final Color color;

 TransactionType(
      {required this.color,
      required this.engName,
      required this.icon,
      required this.index});
}
