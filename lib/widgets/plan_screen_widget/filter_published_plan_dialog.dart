import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/combo_date_plan.dart';
import '../../helpers/util.dart';

// ignore: must_be_immutable
class FilterPublishedPlanDialog extends StatefulWidget {
  FilterPublishedPlanDialog(
      {super.key,
      required this.comboDateIndex,
      required this.maxAmount,
      required this.onChangeComboDate,
      required this.onChangeRange,
      required this.minAmount});
  int comboDateIndex;
  double minAmount;
  double maxAmount;
  void Function(RangeValues rangeValues) onChangeRange;
  void Function(int comboDateIndex) onChangeComboDate;

  @override
  State<FilterPublishedPlanDialog> createState() =>
      _FilterPublishedPlanDialogState();
}

class _FilterPublishedPlanDialogState extends State<FilterPublishedPlanDialog> {
  late int _selectedCombo;
  bool _isSelecting = false;
  late FixedExtentScrollController _scrollController;
  late RangeValues rangeValues;
  late RangeLabels labels;

  @override
  void initState() {
    super.initState();
    _selectedCombo = widget.comboDateIndex;
    _scrollController =
        FixedExtentScrollController(initialItem: widget.comboDateIndex);
    rangeValues = RangeValues(widget.minAmount, widget.maxAmount);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Lọc kế hoạch',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans'),
          ),
          SizedBox(
            height: 1.h,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Thời gian chuyến đi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSans'),
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          _isSelecting
              ? SizedBox(
                  height: 175,
                  child: CupertinoPicker(
                      itemExtent: 64,
                      diameterRatio: 0.7,
                      looping: true,
                      scrollController: _scrollController,
                      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                          background: primaryColor.withOpacity(0.12)),
                      onSelectedItemChanged: (value) {
                        _selectedCombo = value;

                        Future.delayed(
                          const Duration(seconds: 2),
                          () {
                            widget.onChangeComboDate(value);
                            setState(() {
                              _isSelecting = false;
                            });
                          },
                        );
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
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isSelecting = true;
                    });
                    _scrollController = FixedExtentScrollController(
                        initialItem: _selectedCombo);
                  },
                  child: Container(
                      width: 70.w,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: Text(
                        '${listComboDate[_selectedCombo].numberOfDay} ngày, ${listComboDate[_selectedCombo].numberOfNight} đêm',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: RichText(
                text: const TextSpan(
                    text: 'Chi phí bình quân',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NotoSans'),
                    children: [
                  TextSpan(
                      text: '  (GCOIN)',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54))
                ])),
          ),
          SizedBox(
            height: 1.h,
          ),
          RangeSlider(
              activeColor: primaryColor,
              inactiveColor: primaryColor.withOpacity(0.1),
              values: rangeValues,
              divisions: 100,
              labels: RangeLabels(
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: '')
                      .format(rangeValues.start * 30000),
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: '')
                      .format(rangeValues.end * 30000)),
              onChanged: (newValues) {
                widget.onChangeRange(newValues);
                setState(() {
                  rangeValues = newValues;
                });
              }),
          SizedBox(
            height: 1.h,
          ),
          Row(
            children: [
              const Spacer(),
              Container(
                width: 20.w,
                height: 4.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(width: 1, color: Colors.black45)),
                child: Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: '')
                      .format(rangeValues.start * 30000),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSans'),
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              Container(
                width: 3.w,
                height: 2,
                color: Colors.black54,
              ),
              SizedBox(
                width: 2.w,
              ),
              Container(
                width: 20.w,
                height: 4.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(width: 1, color: Colors.black45)),
                child: Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: '')
                      .format(rangeValues.end * 30000),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSans'),
                ),
              ),
              const Spacer()
            ],
          )
        ],
      ),
    );
  }
}
