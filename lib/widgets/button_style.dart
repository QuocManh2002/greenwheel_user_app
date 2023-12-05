import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';

final elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
  textStyle: const TextStyle(fontSize: 18),
  minimumSize: const Size(300, 45),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
);


final outlinedButtonStyle = OutlinedButton.styleFrom(
  side: const BorderSide(width: 2, color: Colors.black),
  foregroundColor: primaryColor,
  textStyle: const TextStyle(fontSize: 18),
  minimumSize: const Size(340, 45),
);

final elevatedButtonStyleWithIcon = ElevatedButton.styleFrom(
  
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
  textStyle: const TextStyle(fontSize: 18),
  minimumSize: const Size(340, 45),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(7),
    ),
  ),
);