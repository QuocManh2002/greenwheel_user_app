import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:sizer2/sizer2.dart';

class TagSearchCard extends StatefulWidget {
  const TagSearchCard({
    super.key,
    required this.tag,
    required this.tags,
    required this.updateTags,
  });
  final Tag tag;
  final List<Tag> tags;
  final Function updateTags; // Callback function

  @override
  State<TagSearchCard> createState() => _TagSearchCardState();
}

class _TagSearchCardState extends State<TagSearchCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isPress = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Check if the tag's ID is in the list of selected tags
    isPress = widget.tags.any((selectedTag) => selectedTag.id == widget.tag.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding
            shape: RoundedRectangleBorder(
              // Add a rounded shape if desired
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: isPress ? Colors.black : Colors.white),
        onPressed: () async {
          setState(() {
            isPress = !isPress;
            widget.updateTags(
                widget.tag, isPress); // Call the callback function
          });
        },
        child: Container(
          width: 11.h,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            border: Border.all(width: 1.7),
          ),
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
    );
  }
}
