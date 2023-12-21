import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class BaseInformationScreen extends StatefulWidget {
  const BaseInformationScreen({super.key});

  @override
  State<BaseInformationScreen> createState() => _BaseInformationState();
}

class _BaseInformationState extends State<BaseInformationScreen> {
  int _selectedCombo = 0;
  int _selectedQuantity = 1;

  onChangeQuantity(String type) {
    if (type == "add") {
      setState(() {
        _selectedQuantity += 1;
      });
    } else {
      setState(() {
        _selectedQuantity -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 2.h,
        ),
        const Text(
          'Thời gian trải nghiệm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 1.h,
        ),
        const Text(
          '(Chưa bao gồm thời gian di chuyển đến địa điểm xuất phát)',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 300,
          child: CupertinoPicker(
              itemExtent: 64,
              diameterRatio: 0.7,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: primaryColor.withOpacity(0.12)),
              onSelectedItemChanged: (value) {
                setState(() {
                  _selectedCombo = value;
                });
              },
              children: Utils.modelBuilder(
                  listComboDates(),
                  (index, model) => Center(
                        child: Text(
                          model,
                          style: TextStyle(
                              fontWeight: _selectedCombo == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedCombo == index
                                  ? primaryColor
                                  : Colors.black),
                        ),
                      ))),
        ),
        SizedBox(
          height: 4.h,
        ),
        const Text(
          'Số lượng thành viên ước tính',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                color: primaryColor,
                iconSize: 30,
                onPressed: () {
                  if (_selectedQuantity > 1) {
                    onChangeQuantity("subtract");
                  }
                },
                icon: const Icon(Icons.remove)),
            Container(
              alignment: Alignment.center,
              height: 5.h,
              width: 10.h,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                _selectedQuantity.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
                color: primaryColor,
                iconSize: 30,
                onPressed: () {
                  onChangeQuantity("add");
                },
                icon: const Icon(Icons.add)),
          ],
        ),
      ],
    );
  }
}
