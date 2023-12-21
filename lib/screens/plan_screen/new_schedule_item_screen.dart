import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';

class NewScheduleItemScreen extends StatelessWidget {
  const NewScheduleItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(context),
      body: Column(
        children: [],
      ),
    ));
  }

  _appBar(BuildContext ctx) {
    return AppBar(
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
      actions: [
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {},
            icon: const Icon(
              Icons.done,
              color: Colors.white,
            ),
            label: const Text('Lưu'))
      ],
    );
  }
}
