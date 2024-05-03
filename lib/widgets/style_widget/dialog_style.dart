import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogStyle {
  void basicDialog(
    {
     required BuildContext context,
    required String title,
    Padding? padding,
    String? desc,
    required DialogType type,
    Color? btnOkColor,
    void Function()? onOk,
    String? btnOkText,
    Color? btnCancelColor,
    void Function()? onCancel,
    String? btnCancelText
    }
  ) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.warning,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            title: title,
            titleTextStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
            desc: desc,
            descTextStyle: const TextStyle(
                fontSize: 15, fontFamily: 'NotoSans', color: Colors.grey),
            btnOkColor: btnOkColor ?? Colors.amber,
            btnOkText: btnOkText ?? 'OK',
            btnOkOnPress: onOk ?? (){},
            btnCancelColor: btnCancelColor ,
            btnCancelOnPress: onCancel ,
            btnCancelText: btnCancelText 
                )
        .show();
  }
}
