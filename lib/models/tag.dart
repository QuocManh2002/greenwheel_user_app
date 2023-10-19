import 'package:flutter/material.dart';

class Tag{
   Tag({required this.id, required this.title, required this.mainColor, this.strokeColor});

  final String id;
  final String title;
  final Color mainColor;
  Color? strokeColor;
}