import 'package:flutter/material.dart';

class Tag {
  Tag(
      {required this.id,
      required this.title,
      required this.mainColor,
      required this.type,
      required this.enumName,
      this.strokeColor});

  final String id;
  final String title;
  final String type;
  final Color mainColor;
  final String enumName;
  Color? strokeColor;
}
