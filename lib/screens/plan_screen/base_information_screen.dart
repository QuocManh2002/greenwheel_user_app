import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class BaseInformationScreen extends StatefulWidget {
  const BaseInformationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<BaseInformationScreen> createState() => _BaseInformationState();
}

class _BaseInformationState extends State<BaseInformationScreen> {
  int _selectedCombo = 0;
  int _selectedQuantity = 1;
  late FixedExtentScrollController _scrollController;
  bool isWarning = false;
  ComboDate? _suggestComboDate;

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
    sharedPreferences.setInt('plan_number_of_member', _selectedQuantity);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? combodate = sharedPreferences.getInt('plan_combo_date');
    if (combodate != null) {
      _scrollController = FixedExtentScrollController(initialItem: combodate);
    } else {
      final defaultComboDate = listComboDate
              .firstWhere((element) =>
                  element.duration == widget.location.suggestedTripLength)
              .id -
          1;
      sharedPreferences.setInt('plan_combo_date', defaultComboDate);
      _scrollController =
          FixedExtentScrollController(initialItem: defaultComboDate);
    }
    if (member != null) {
      setState(() {
        _selectedQuantity = member;
      });
    }
    _suggestComboDate = listComboDate.firstWhere(
        (element) => element.duration == widget.location.suggestedTripLength);
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
              looping: true,
              scrollController: _scrollController,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: primaryColor.withOpacity(0.12)),
              onSelectedItemChanged: (value) {
                setState(() {
                  _selectedCombo = value;
                });
                if (listComboDate[value].duration <
                    widget.location.suggestedTripLength) {
                  setState(() {
                    isWarning = true;
                  });
                }else{
                  setState(() {
                    isWarning = false;
                  });
                }
                sharedPreferences.setBool("plan_is_change", false);
                sharedPreferences.setInt('plan_combo_date', value);
              },
              children: Utils.modelBuilder(
                  listComboDate,
                  (index, model) => Center(
                        child: Text(
                          '${model.numberOfDay} ngày, ${model.numberOfNight} đêm',
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
          height: 2.h,
        ),
        if (isWarning)
          Text(
            '(Địa điểm này thích hợp hơn với các chuyến đi có thời gian trải nghiệm từ ${_suggestComboDate!.numberOfDay} ngày, ${_suggestComboDate!.numberOfNight} đêm.)',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        SizedBox(
          height: 2.h,
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
