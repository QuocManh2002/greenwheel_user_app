import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreatePlanSurcharge extends StatefulWidget {
  const CreatePlanSurcharge(
      {super.key,
      this.surcharge,
      required this.callback,
      required this.isCreate});
  final void Function() callback;
  final bool isCreate;
  final SurchargeViewModel? surcharge;
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
      SurchargeViewModel sur = SurchargeViewModel(
          alreadyDivided: alreadyDivided,
          gcoinAmount: amount,
          note: _noteController.text);
          print(sur.id);
      final surchargeObject = sur.toJson();
      print(surchargeObject['id']);
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

  onUpdateSurcharge() {
    if (_formKey.currentState!.validate()) {
      String? surchargeText = sharedPreferences.getString('plan_surcharge');
      var list = json.decode(surchargeText!);
      log('1  $surchargeText');
      var initSurcharge = list.firstWhere((e) => e['id'] == widget.surcharge!.id);
      var initIndex = list.indexOf(initSurcharge);
      
      list[initIndex]['note'] = json.encode(_noteController.text);
      list[initIndex]['gcoinAmount'] = amount;
      list[initIndex]['alreadyDivided'] = alreadyDivided;

      sharedPreferences.setString('plan_surcharge', json.encode(list));
      Navigator.of(context).pop();
      widget.callback();



      // if (surchargeText == null) {
      //   sharedPreferences.setString(
      //       'plan_surcharge', json.encode([surchargeObject]));
      // } else {
      //   List<dynamic> surchargeList = json.decode(surchargeText);
      //   surchargeList.add(surchargeObject);
      //   sharedPreferences.setString(
      //       'plan_surcharge', json.encode(surchargeList));
      // }
      // Navigator.of(context).pop();
      // widget.callback();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    if (!widget.isCreate) {
      _noteController.text = json.decode(widget.surcharge!.note);
      amount = widget.surcharge!.gcoinAmount;
      alreadyDivided = widget.surcharge!.alreadyDivided;
      _amountController.text =
          NumberFormat('###,###,##0', 'vi_VN').format(amount);
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
                  } else if (amount < 1000 || amount > 1000000) {
                    return "Phụ thu phải trong khoản từ 1000 đến 1000000";
                  }
                },
                onChange: (value) {
                  if (value != "") {
                    setState(() {
                      amount = NumberFormat('###,###,##0', 'vi_VN')
                        .parse(value!)
                        .toInt();
                    });
                    _amountController.text =
                        NumberFormat('###,###,##0', 'vi_VN').format(amount);
                  }
                },
                inputType: TextInputType.number),
            const SizedBox(
              height: 32,
            ),
            TextFormFieldWithLength(
                maxLength: 40,
                maxline: 2,
                text: 'Ghi chú phụ thu',
                hinttext: 'Mua bia về nhậu,...',
                controller: _noteController,
                minline: 2,
                onValidate: (value) {
                  if (value == null || value.trim() == '') {
                    return "Ghi chú phụ thu không được để trống";
                  }else if(value.length <2 || value.length > 40){
                    return "Ghi chú phụ thu phải có độ dài từ 2 - 40 kí tự";
                  }
                },
                onChange: (p0) {
                  setState(() {
                    _noteController.text = p0!;
                  });
                },
                inputType: TextInputType.text),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Checkbox(
                    activeColor: primaryColor,
                    value: alreadyDivided,
                    onChanged: (value) {
                      setState(() {
                        alreadyDivided = !alreadyDivided;
                      });
                    }),
                SizedBox(
                  width: 70.w,
                  child: const Text(
                    'Đã chia đều cho các thành viên',
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 17, fontFamily: 'NotoSans'),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed: widget.isCreate
                  ? onCreateSurcharge
                  : ("${_noteController.text}" !=
                              json.decode(widget.surcharge!.note) ||
                        amount != widget.surcharge!.gcoinAmount ||
                          alreadyDivided != widget.surcharge!.alreadyDivided)
                      ? onUpdateSurcharge
                      : null,
              icon: const Icon(Icons.check),
              style: elevatedButtonStyle,
              label: const Text('Lưu'),
            )
          ]),
        ),
      ),
    ));
  }
}
