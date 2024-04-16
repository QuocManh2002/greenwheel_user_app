
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:sizer2/sizer2.dart';

class CustomPlanItem extends StatefulWidget {
  const CustomPlanItem(
      {super.key,
      required this.title,
      required this.details,
      required this.onDismiss,
      required this.onAddNewItem});
  final String title;
  final List<String> details;
  final void Function(String item, List<String> list) onDismiss;
  final void Function(List<String> list) onAddNewItem;

  @override
  State<CustomPlanItem> createState() => _CustomPlanItemState();
}

class _CustomPlanItemState extends State<CustomPlanItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only( top: 8),
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontSize: 18),
                      ),
                      AnimatedSwitcher(
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns:
                                Tween(begin: 0.8, end: 1.0).animate(animation),
                            child: child,
                          );
                        },
                        duration: const Duration(microseconds: 300),
                        child: Image.asset(
                          isExpanded ? GlobalConstant().upIcon : GlobalConstant().downIcon,
                          height: 2.h,
                          fit: BoxFit.cover,
                          key: ValueKey(isExpanded),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              height: (widget.details.length * 5.7).h,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black12,
                    offset: Offset(1, 3),
                  )
                ],
                // borderRadius: BorderRadius.only(
                //     bottomRight: Radius.circular(12),
                //     bottomLeft: Radius.circular(12))
              ),
              child: ReorderableListView.builder(
                itemCount: widget.details.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    key: ValueKey(widget.details[index]),
                    padding: const EdgeInsets.only(
                        left: 32, top: 2.5, bottom: 2.5, right: 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                          border: Border(
                        bottom: BorderSide(color: Colors.black26, width: 1.5),
                        left: BorderSide(color: Colors.black26, width: 1.5),
                        right: BorderSide(color: Colors.black26, width: 1.5),
                        top: BorderSide(color: Colors.black26, width: 1.5),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                      height: 5.h,
                      child: Dismissible(
                        key: ValueKey(widget.details[index]),
                        background: Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                          ),
                          alignment: Alignment.centerLeft,
                          height: 5.h,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: redColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          child: const Icon(Icons.delete),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.only(right: 16),
                          alignment: Alignment.centerRight,
                          height: 5.h,
                          decoration: const BoxDecoration(
                            color: redColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const Icon(Icons.delete),
                        ),
                        onDismissed: (direction) {
                          widget.onDismiss(
                              widget.details[index], widget.details);
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: Text(
                              widget.details[index],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                    final item = widget.details.removeAt(oldIndex);
                    widget.details.insert(index, item);
                  });
                },
              ),
            ),
          ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: InkWell(
              onTap: () {
                widget.onAddNewItem(widget.details);
              },
              child: Container(
                height: 5.7.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black12,
                        offset: Offset(1, 3),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 8, bottom: 8),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(8))
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 16, top: 8, right: 12, bottom: 8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Thêm hoạt động",
                            style: TextStyle(fontSize: 18),
                          ),
                          Icon(Icons.add)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
