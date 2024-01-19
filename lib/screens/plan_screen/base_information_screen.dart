import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
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
    setUpData();
    var dis = 276227 / 1000;
    print(dis.toStringAsFixed(2));
    var dur = 22038 / 3600;
    print(dur.toStringAsFixed(2));
  }

  setUpData() {
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? numOfExpPeriod = sharedPreferences.getInt('numOfExpPeriod');
    ComboDate _selectedComboDate;
    if (numOfExpPeriod != null) {
      _selectedComboDate = listComboDate.firstWhere(
        (element) =>
            element.numberOfDay + element.numberOfNight == numOfExpPeriod,
      );

      setState(() {
        _selectedCombo = _selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: _selectedComboDate.id - 1);
      });
    } else {
      _selectedComboDate = listComboDate.firstWhere((element) =>
          element.duration == widget.location.suggestedTripLength * 2);
      sharedPreferences.setInt('plan_combo_date', _selectedComboDate.id - 1);
      sharedPreferences.setInt('numOfExpPeriod',
          _selectedComboDate.numberOfDay + _selectedComboDate.numberOfNight);
      setState(() {
        _selectedCombo = _selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: _selectedComboDate.id - 1);
      });
    }
    sharedPreferences.setInt('plan_combo_date', _selectedComboDate.id - 1);
    if (member != null) {
      setState(() {
        _selectedQuantity = member;
      });
    } else {
      sharedPreferences.setInt('plan_number_of_member', 1);
    }
    _suggestComboDate = listComboDate.firstWhere((element) =>
        element.duration == widget.location.suggestedTripLength * 2);
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
          'Chưa bao gồm thời gian di chuyển đến địa điểm xuất phát',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 230,
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
                    widget.location.templatePlan.length * 2) {
                  setState(() {
                    isWarning = true;
                  });
                } else {
                  setState(() {
                    isWarning = false;
                  });
                }
                sharedPreferences.setInt('plan_combo_date', value);
                sharedPreferences.setInt(
                    'numOfExpPeriod',
                    listComboDate[value].numberOfDay +
                        listComboDate[value].numberOfNight);
                sharedPreferences.setBool('plan_is_change', false);
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
            'Địa điểm này thích hợp hơn với các chuyến đi có thời gian trải nghiệm từ ${_suggestComboDate!.numberOfDay} ngày, ${_suggestComboDate!.numberOfNight} đêm.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        if (isWarning)
          SizedBox(
            height: 2.h,
          ),
        SizedBox(
          height: 6.h,
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
