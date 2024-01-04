import 'package:choose_input_chips/choose_input_chips.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer2/sizer2.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

const List<Tag> listTags = [];

class _MyWidgetState extends State<MyWidget> {
  final _chipKey = GlobalKey<ChipsInputState>();
  String searchTerm = "";
  List<String> tagNames = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChipsInput(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    // setState(() {
                    //   var tagsByName =
                    //       searchTagsByName(searchController.text);
                    //   if (tagsByName.isEmpty) {
                    //     // var locationsByName =
                    //     //     searchTagsByName(searchController.text);
                    //   } else {
                    //     setState(() {
                    //       // Iterate over tagsByName
                    //       for (Tag tag in tagsByName) {
                    //         // Check if any tag in currentTags has the same title
                    //         bool titleExists = currentTags.any(
                    //             (existingTag) =>
                    //                 existingTag.title == tag.title);

                    //         // If the title doesn't exist, add the tag to currentTags
                    //         if (!titleExists) {
                    //           currentTags.add(tag);
                    //         }
                    //       }
                    //     });
                    //   }
                    // });
                    // List<LocationViewModel> result = await locationService
                    //     .searchLocations(searchController.text, currentTags);
                    // setState(() {
                    //   locations = result;
                    // });
                  },
                ),
                hintText: "Bạn có dự định đi đâu?",
                contentPadding: EdgeInsets.all(4.w),
              ),
              key: _chipKey,
              // initialValue: [mockResults[3]],
              allowChipEditing: true,
              textStyle: const TextStyle(
                height: 1.5,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              findSuggestions: (String query) {
                if (query.isNotEmpty) {
                  var lowercaseQuery = query.toLowerCase();
                  var tmp = tags.where((tag) {
                    return tag.title
                        .toLowerCase()
                        .contains(query.toLowerCase());
                    //     ||
                    // tag.enumName
                    //     .toLowerCase()
                    //     .contains(query.toLowerCase());
                  }).toList(growable: false)
                    ..sort((a, b) => a.title
                        .toLowerCase()
                        .indexOf(lowercaseQuery)
                        .compareTo(
                            b.title.toLowerCase().indexOf(lowercaseQuery)));
                  setState(() {
                    searchTerm = query;
                  });
                  print("SEARCH TERM: $searchTerm");
                  return tmp;
                }
                // return mockResults;
                return listTags;
              },
              onChanged: (data) {
                // this is a good place to update application state
                tagNames = [];
                for (var element in data) {
                  setState(() {
                    tagNames.add(element.title);
                  });
                }
                print("SEARCH TERM: $searchTerm");
                for (var element in tagNames) {
                  print(element);
                }
                print(tagNames.length);
              },
              chipBuilder: (context, state, dynamic tag) {
                return InputChip(
                  key: ObjectKey(tag),
                  label: Text(tag.title),
                  // avatar: CircleAvatar(
                  //   backgroundImage:
                  //       AssetImage('assets/avatars/${tag.title}'),
                  // ),
                  onDeleted: () => state.deleteChip(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
              suggestionBuilder: (context, state, dynamic tag) {
                return ListTile(
                  key: ObjectKey(tag),
                  // leading: CircleAvatar(
                  //   backgroundImage:
                  //       AssetImage('assets/avatars/${tag.title}'),
                  // ),
                  title: Text(tag.title),
                  // subtitle: Text(profile.email),
                  onTap: () => {
                    state.selectSuggestion(tag),
                    setState(() {
                      searchTerm = "";
                    }),
                    print("SEARCH TERM SELECTED: $searchTerm")
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
