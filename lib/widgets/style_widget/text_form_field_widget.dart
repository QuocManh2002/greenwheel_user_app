import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';

Widget defaultTextFormField(
        {required TextEditingController controller,
        required TextInputType inputType,
        Function(String?)? onFieldSubmit,
        VoidCallback? onTap,
        String? Function(String?)? onValidate,
        Function(String?)? onChange,
        String? text,
        Widget? prefixIcon,
        Widget? suffixIcon,
        bool obscure = false,
        InputBorder? border,
        String? hinttext,
        int? maxligne,
        bool readonly = false}) =>
    TextFormField(
        controller: controller,
        keyboardType: inputType,
        onFieldSubmitted: onFieldSubmit,
        onTap: onTap,
        maxLines: maxligne ?? 1,
        readOnly: readonly,
        obscureText: obscure,
        onChanged: onChange,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        decoration: InputDecoration(
            labelText: text,
            hintText: hinttext ?? null,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixIconColor: primaryColor,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: const TextStyle(color: primaryColor, fontSize: 20),
            floatingLabelStyle:
                const TextStyle(color: Colors.grey, fontSize: 20),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(14))),
            border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(Radius.circular(14)))),
        validator: onValidate);
