
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';

class TabButton extends StatelessWidget {
  const TabButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.index,
  });
  final String text;
  final bool isSelected;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryColor.withOpacity(0.3),
          shape: BoxShape.rectangle,
          borderRadius:const BorderRadius.all(Radius.circular(12))),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
