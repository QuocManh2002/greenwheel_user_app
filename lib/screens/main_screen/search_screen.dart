import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/tag.dart';
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
  });
  final String search;
  final List<Tag> list;
  final List<Tag> provinces;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final LocationService locationService = LocationService();

  TextEditingController searchController = TextEditingController();

  List<Tag> currentTags = [];
  List<LocationViewModel> locations = [];

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
  }

  _setUpData() async {
    searchController.text = widget.search;
    currentTags = widget.list;
    if (locations.isEmpty) {
      locations = await locationService.getLocations();
    }

    if (locations.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
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
                Expanded(
                  child: TextField(
                    controller: searchController,
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
                        onPressed: () {
                          setState(() {
                            var tagsByName =
                                searchTagsByName(searchController.text);
                            if (tagsByName.isEmpty) {
                              // var locationsByName =
                              //     searchTagsByName(searchController.text);
                              print("empty");
                            } else {
                              print("not empty");
                              setState(() {
                                currentTags.addAll(tagsByName);
                              });
                            }
                          });
                        },
                      ),
                      hintText: "Bạn có dự định đi đâu?",
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                  ),
                ),
                (searchController.text.isEmpty)
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => SearchCategoryScreen(
                                list: currentTags,
                                search: searchController.text,
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
        body: (searchController.text.isEmpty)
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
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    currentTags.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8, top: 14),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: SizedBox(
                                    height: 4.h,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: currentTags.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child:
                                            TagWidget(tag: currentTags[index]),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    widget.list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, top: 14, bottom: 14),
                            child: Text(
                              'Kết quả tìm kiếm của "${searchController.text}"',
                              style: const TextStyle(
                                fontSize: 19,
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      height: 80.h,
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

  List<Tag> searchTagsByName(String query) {
    // Create an empty list to store the search results
    List<Tag> searchResults = [];

    // Split the query into multiple search terms
    List<String> searchTerms = query.trim().toLowerCase().split(' ');

    // Perform a case-insensitive search for tags by each search term
    for (String term in searchTerms) {
      for (Tag tag in tags) {
        if (tag.title.toLowerCase() == (term)) {
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
