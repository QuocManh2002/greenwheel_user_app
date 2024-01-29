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
        int? maxline,
        bool readonly = false}) =>
    TextFormField(
        controller: controller,
        keyboardType: inputType,
        onFieldSubmitted: onFieldSubmit,
        onTap: onTap,
        maxLines: maxline ?? 1,
        minLines: 1,
        readOnly: readonly,
        obscureText: obscure,
        onChanged: onChange,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        decoration: InputDecoration(
            labelText: text,
            hintText: hinttext,
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

Widget TextFormFieldWithLength(
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
        int? maxline,
        int? minline,
        int? maxLength,
        bool? isAutoFocus,
        bool readonly = false}) =>
    TextFormField(
        controller: controller,
        keyboardType: inputType,
        autofocus: isAutoFocus ?? false,
        onFieldSubmitted: onFieldSubmit,
        onTap: onTap,
        maxLines: maxline ?? 1,
        minLines: minline ?? 1,
        readOnly: readonly,
        maxLength: maxLength ?? 120,
        obscureText: obscure,
        onChanged: onChange,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        decoration: InputDecoration(
            labelText: text,
            counterText: '',
            contentPadding:const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
