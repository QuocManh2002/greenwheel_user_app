import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/main_screen/home.dart';
import 'package:greenwheel_user_app/screens/main_screen/search_category.dart';
import 'package:greenwheel_user_app/widgets/recent_card.dart';
import 'package:greenwheel_user_app/widgets/location_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/constants/recent_search.dart';
import 'package:greenwheel_user_app/constants/locations.dart';
import 'package:greenwheel_user_app/constants/plans.dart';
import 'package:greenwheel_user_app/widgets/search_card.dart';
import 'package:greenwheel_user_app/widgets/tag.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.search = '', this.list = const []});
  final String search;
  final List<Tag> list;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
  }

  _setUpData() {
    searchController.text = widget.search;
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
                        builder: (ctx) => const HomeScreen(),
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
                      // prefixIcon: const Icon(
                      //   Icons.search,
                      //   color: Colors.black,
                      // ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // setState(() {
                          //   search.text = "";
                          // });
                          Navigator.of(context).pop(); // Close the current page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  SearchScreen(search: searchController.text),
                            ),
                          );
                        },
                      ),
                      hintText: "Bạn có dự định đi đâu?",
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Handle threedot icon action here
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => SearchCategoryScreen(
                          list: widget.list,
                          search: widget.search,
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
                    widget.list.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: SizedBox(
                                    height: 4.h,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: widget.list.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child:
                                            TagWidget(tag: widget.list[index]),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 14),
                      child: Text(
                        'Kết quả tìm kiếm của "${searchController.text}"',
                        style: const TextStyle(
                          fontSize: 19,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        return SearchCard(location: locations[index]);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
