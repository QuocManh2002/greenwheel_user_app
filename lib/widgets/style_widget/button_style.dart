import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:sizer2/sizer2.dart';

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

final elevatedButtonStyleNoSize = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
  textStyle: const TextStyle(fontSize: 18),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
);

final outlinedButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
      side: BorderSide(color: primaryColor),
      borderRadius: BorderRadius.all(Radius.circular(10))),
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

final profileButtonStyle = ElevatedButton.styleFrom(
    alignment: const Alignment(-1, 0),
    minimumSize: Size(100.w, 6.h),
    shadowColor: primaryColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))));
