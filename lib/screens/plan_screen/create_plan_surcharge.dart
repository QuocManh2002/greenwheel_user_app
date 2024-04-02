import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreatePlanSurcharge extends StatefulWidget {
  const CreatePlanSurcharge({super.key, required this.callback});
  final void Function() callback;
  @override
  State<CreatePlanSurcharge> createState() => _CreatePlanSurchargeState();
}

class _CreatePlanSurchargeState extends State<CreatePlanSurcharge> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  bool alreadyDivided = false;
  int amount = 0;
  onCreateSurcharge() {
    if (_formKey.currentState!.validate()) {
      String? surchargeText = sharedPreferences.getString('plan_surcharge');
      final surchargeObject = {
        'note': json.encode(_noteController.text),
        'gcoinAmount': amount,
        'alreadyDivided': alreadyDivided
      };
      if (surchargeText == null) {
        sharedPreferences.setString(
            'plan_surcharge', json.encode([surchargeObject]));
      } else {
        List<dynamic> surchargeList = json.decode(surchargeText);
        surchargeList.add(surchargeObject);
        sharedPreferences.setString(
            'plan_surcharge', json.encode(surchargeList));
      }
      Navigator.of(context).pop();
      widget.callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Tạo khoản phụ thu'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(
              height: 32,
            ),
            defaultTextFormField(
                text: 'Khoản phụ thu (GCOIN)',
                hinttext: '10, 100, 1000,...',
                controller: _amountController,
                onValidate: (value) {
                  if (value == null || value.trim() == '') {
                    return "Khoản phụ thu không được để trống";
                  } else if (amount < 1000 ||
                      amount > 10000000) {
                    return "Phụ thu phải trong khoản từ 1000 đến 1000000";
                  }
                },
                onChange: (value) {
                  if (value != "") {
                    amount = NumberFormat('###,###,##0', 'vi_VN')
                        .parse(value!)
                        .toInt();
                    _amountController.text =
                        NumberFormat('###,###,##0', 'vi_VN').format(amount);
                  }
                },
                inputType: TextInputType.number),
            const SizedBox(
              height: 32,
            ),
            defaultTextFormField(
                maxLength: 40,
                maxline: 2,
                text: 'Ghi chú phụ thu',
                hinttext: 'Mua bia về nhậu,...',
                controller: _noteController,
                onValidate: (value) {
                  if (value == null || value.trim() == '') {
                    return "Ghi chú phụ thu không được để trống";
                  }
                },
                inputType: TextInputType.text),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: primaryColor,
                  value: alreadyDivided, onChanged: (value){
                  setState(() {
                    alreadyDivided = !alreadyDivided;
                  });
                }),
                SizedBox(width: 70.w,
                child:const Text(
                  'Đã chia đều cho các thành viên',
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 17, fontFamily: 'NotoSans'
                  ),
                ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed: onCreateSurcharge,
              icon: const Icon(Icons.add),
              style: elevatedButtonStyle,
              label: const Text('Thêm'),
            )
          ]),
        ),
      ),
    ));
  }
}
