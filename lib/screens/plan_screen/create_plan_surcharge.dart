import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';

class CreatePlanSurcharge extends StatefulWidget {
  const CreatePlanSurcharge({super.key, required this.callback});
  final void Function(String amount, String note) callback;
  @override
  State<CreatePlanSurcharge> createState() => _CreatePlanSurchargeState();
}

class _CreatePlanSurchargeState extends State<CreatePlanSurcharge> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

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
        child: Column(children: [
          const SizedBox(
            height: 32,
          ),
          defaultTextFormField(
              text: 'Khoản phụ thu (GCOIN)',
              hinttext: '10, 100, 1000,...',
              controller: _amountController,
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
              inputType: TextInputType.text),
          const SizedBox(
            height: 32,
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.callback(_amountController.text, _noteController.text);
            },
            icon: const Icon(Icons.add),
            style: elevatedButtonStyle,
            label: const Text('Thêm'),
          )
        ]),
      ),
    ));
  }
}
