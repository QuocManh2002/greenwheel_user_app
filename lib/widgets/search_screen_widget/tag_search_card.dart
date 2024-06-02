import 'package:flutter/material.dart';
import 'package:phuot_app/models/tag.dart';
import 'package:sizer2/sizer2.dart';

class TagSearchCard extends StatefulWidget {
  const TagSearchCard({
    super.key,
    required this.tag,
    required this.tags,
    required this.updateTags,
    this.updateProvinces,
  });
  final Tag tag;
  final List<Tag> tags;
  final Function updateTags; // Callback function
  final Function? updateProvinces;

  @override
  State<TagSearchCard> createState() => _TagSearchCardState();
}

class _TagSearchCardState extends State<TagSearchCard> {
  bool isPress = false;

  @override
  void initState() {
    super.initState();
    // Check if the tag's ID is in the list of selected tags
    isPress = widget.tags.any((selectedTag) => selectedTag.id == widget.tag.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        height: 4.h,
        width: 10.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Remove default padding
              shape: RoundedRectangleBorder(
                // Add a rounded shape if desired
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: isPress
                  ? const Color.fromARGB(255, 94, 212, 98)
                  : const Color.fromARGB(255, 233, 233, 233)),
          onPressed: () async {
            setState(() {
              isPress = !isPress;
              widget.updateTags(
                  widget.tag, isPress); // Call the callback function
              if (widget.tag.id == "20" ||
                  widget.tag.id == "21" ||
                  widget.tag.id == "22") {
                widget.updateProvinces!(widget.tag, isPress);
              }
            });
          },
          child: SizedBox(
            // decoration: BoxDecoration(
            //   shape: BoxShape.rectangle,
            //   borderRadius: const BorderRadius.all(
            //     Radius.circular(10),
            //   ),
            //   border: Border.all(width: 1.7),
            // ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                widget.tag.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPress ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
