import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

// ignore: must_be_immutable
class PlanJoinMethod extends StatefulWidget {
  PlanJoinMethod(
      {super.key,
      required this.joinMethod,
      required this.updateJoinMethod});
  String joinMethod;
  final void Function(String joinMethod) updateJoinMethod;

  @override
  State<PlanJoinMethod> createState() => _PlanJoinMethodState();
}

class _PlanJoinMethodState extends State<PlanJoinMethod> {
  Color? color = Colors.grey;

  @override
  void initState() {
    super.initState();
  }

  getJoinMethodColor(String method) {
    switch (method) {
      case 'NONE':
        return Colors.grey;
      case 'INVITE':
        return Colors.blue;
      case 'SCAN':
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    color = getJoinMethodColor(widget.joinMethod);
    return Container(
            width: 27.w,
            padding: EdgeInsets.only(left: 1.w),
            decoration: BoxDecoration(
                border: Border.all(color: color!, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            child: DropdownButton<String>(
              iconEnabledColor: color,
              iconSize: 30,
              underline: const SizedBox(),
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(color: Colors.black, fontSize: 18),
              value: widget.joinMethod,
              onChanged: (value) {
                widget.updateJoinMethod(value!);
                setState(() {
                  widget.joinMethod = value;
                  color = getJoinMethodColor(value);
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'NONE',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      const Text(
                        'Đóng',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            color: Colors.grey),
                      )
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'INVITE',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 18,
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      const Text(
                        'Mời',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            color: Colors.blue),
                      )
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'SCAN',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        color: Colors.orange,
                        size: 18,
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      const Text(
                        'QR',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            color: Colors.orange),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
