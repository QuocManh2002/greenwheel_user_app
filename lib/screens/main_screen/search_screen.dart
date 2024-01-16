import 'package:choose_input_chips/choose_input_chips.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/search.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/loading_screen/search_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/search_category_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/style_widget/recent_card.dart';
import 'package:greenwheel_user_app/widgets/home_screen_widget/location_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/constants/recent_search.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/search_card.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/tag.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.search = '',
    this.list = const [],
    this.provinces = const [],
    required this.searchState,
  });
  final String search;
  final List<Tag> list;
  final List<Tag> provinces;
  final bool searchState;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final LocationService locationService = LocationService();

  List<Tag> currentTags = [];
  List<LocationViewModel> locations = [];

  bool isLoading = false;
  bool isSearch = false;

  final _chipKey = GlobalKey<ChipsInputState>();
  String searchTerm = "";
  String searchedTxt = "";
  List<String> tagNames = [];
  List<Tag> listTags = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
  }

  _setUpData() async {
    searchTerm = widget.search;
    currentTags = List.from(widget.list);
    setState(() {
      isSearch = widget.searchState;
    });
    if (isSearch) {
      List<LocationViewModel> result =
          await locationService.searchLocations(searchTerm, currentTags);
      setState(() {
        locations = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: AppBar(
            flexibleSpace: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Handle return icon action here
                      Navigator.of(context).pop(); // Close the current page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const TabScreen(
                            pageIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  // Expanded(
                  //   child: TextField(
                  //     controller: searchController,
                  //     decoration: InputDecoration(
                  //       enabledBorder: OutlineInputBorder(
                  //         borderSide:
                  //             const BorderSide(width: 1, color: Colors.grey),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide:
                  //             const BorderSide(width: 1, color: Colors.black),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       suffixIcon: IconButton(
                  //         icon: const Icon(
                  //           Icons.search,
                  //           color: Colors.black,
                  //         ),
                  //         onPressed: () async {
                  //           // setState(() {
                  //           //   var tagsByName =
                  //           //       searchTagsByName(searchController.text);
                  //           //   if (tagsByName.isEmpty) {
                  //           //     // var locationsByName =
                  //           //     //     searchTagsByName(searchController.text);
                  //           //   } else {
                  //           //     setState(() {
                  //           //       // Iterate over tagsByName
                  //           //       for (Tag tag in tagsByName) {
                  //           //         // Check if any tag in currentTags has the same title
                  //           //         bool titleExists = currentTags.any(
                  //           //             (existingTag) =>
                  //           //                 existingTag.title == tag.title);

                  //           //         // If the title doesn't exist, add the tag to currentTags
                  //           //         if (!titleExists) {
                  //           //           currentTags.add(tag);
                  //           //         }
                  //           //       }
                  //           //     });
                  //           //   }
                  //           // });
                  //           List<LocationViewModel> result =
                  //               await locationService.searchLocations(
                  //                   searchController.text, currentTags);
                  //           setState(() {
                  //             locations = result;
                  //           });
                  //         },
                  //       ),
                  //       hintText: "Bạn có dự định đi đâu?",
                  //       contentPadding: EdgeInsets.all(4.w),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: ChipsInput(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            setState(() {
                              var tagsByName = searchTagsInList(tagNames);
                              if (tagsByName.isEmpty) {
                                // var locationsByName =
                                //     searchTagsByName(searchController.text);
                              } else {
                                setState(() {
                                  // Iterate over tagsByName
                                  for (Tag tag in tagsByName) {
                                    // Check if any tag in currentTags has the same title
                                    bool titleExists = currentTags.any(
                                        (existingTag) =>
                                            existingTag.title == tag.title);

                                    // If the title doesn't exist, add the tag to currentTags
                                    if (!titleExists) {
                                      currentTags.add(tag);
                                    }
                                  }
                                });
                              }
                            });
                            List<LocationViewModel> result =
                                await locationService.searchLocations(
                                    searchTerm, currentTags);
                            setState(() {
                              searchedTxt = searchTerm;
                              locations = result;
                              isSearch = true;
                            });
                            print(result.length);
                          },
                        ),
                        hintText: "Bạn có dự định đi đâu?",
                        contentPadding: EdgeInsets.all(4.w),
                      ),
                      key: _chipKey,
                      // initialValue: [mockResults[3]],
                      maxChips: 2,
                      allowChipEditing: true,
                      textStyle: const TextStyle(
                        height: 1.5,
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                      findSuggestions: (String query) {
                        if (query.isNotEmpty) {
                          var lowercaseQuery = query.toLowerCase();
                          var tmp = searchTags.where((tag) {
                            return tag.title
                                .toLowerCase()
                                .contains(query.toLowerCase());
                            //     ||
                            // tag.subName
                            //     .toLowerCase()
                            //     .contains(query.toLowerCase());
                          }).toList(growable: false)
                            ..sort((a, b) => a.title
                                .toLowerCase()
                                .indexOf(lowercaseQuery)
                                .compareTo(b.title
                                    .toLowerCase()
                                    .indexOf(lowercaseQuery)));
                          setState(() {
                            searchTerm = query;
                          });
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                          },
                        );
                      },
                    ),
                  ),
                  (locations.isEmpty)
                      ? Container(
                          margin: const EdgeInsets.only(right: 20),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Handle threedot icon action here
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => SearchCategoryScreen(
                                  list: currentTags,
                                  search: searchTerm,
                                  provinceList: widget.provinces,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
        body: (isSearch == false)
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          // Image that can change size
                          Image.asset(
                            'assets/images/map-marker.png',
                          ),
                          // Container with text above and below
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tìm địa điểm gần bạn',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Vị trí hiện tại - Tp.HCM',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 1.8,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Tìm kiếm gần đây",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 26.h,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: recent.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: RecentCard(recent: recent[index]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Dành cho bạn",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: SizedBox(
                            height: 30.h,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: locations.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: LocationCard(location: locations[index]),
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : (isLoading)
                ? const SingleChildScrollView(
                    child: SearchLoadingScreen(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        currentTags.isNotEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, top: 14),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SizedBox(
                                        height: 4.h,
                                        child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: currentTags.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) =>
                                              Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: TagWidget(
                                                tag: currentTags[index]),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        (searchedTxt != '')
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 14, bottom: 10),
                                child: Text(
                                  'Kết quả tìm kiếm của "${searchTerm.trim()}"',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontFamily: 'NotoSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          height: 70.h,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: locations.length,
                            itemBuilder: (context, index) {
                              return SearchCard(location: locations[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // List<Tag> searchTagsByName(String query) {
  //   // Create an empty list to store the search results
  //   List<Tag> searchResults = [];

  //   // Split the query into multiple search terms
  //   List<String> searchTerms = query.trim().toLowerCase().split(' ');

  //   // Perform a case-insensitive search for tags by each search term
  //   for (String term in searchTerms) {
  //     for (Tag tag in tags) {
  //       if (tag.title.toLowerCase() == (term)) {
  //         // Add the tag to the search results if its title contains the search term
  //         searchResults.add(tag);
  //       }
  //     }
  //   }

  //   // Remove duplicates by creating a Set and converting it back to a List
  //   searchResults = searchResults.toSet().toList();

  //   return searchResults;
  // }

  List<Tag> searchTagsInList(List<String> list) {
    // Create an empty list to store the search results
    List<Tag> searchResults = [];

    // Perform a case-insensitive search for tags by each search term
    for (String term in list) {
      for (Tag tag in searchTags) {
        if (tag.title.toLowerCase() == (term.toLowerCase())) {
          // Add the tag to the search results if its title contains the search term
          searchResults.add(tag);
        }
      }
    }

    // Remove duplicates by creating a Set and converting it back to a List
    searchResults = searchResults.toSet().toList();
    return searchResults;
  }
}
