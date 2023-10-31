import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/main_screen/search_screen.dart';
import 'package:greenwheel_user_app/widgets/tag_search_card.dart';
import 'package:sizer2/sizer2.dart';

class SearchCategoryScreen extends StatefulWidget {
  const SearchCategoryScreen({
    super.key,
    required this.list,
    required this.search,
  });
  final String search;
  final List<Tag> list;

  @override
  State<SearchCategoryScreen> createState() => _SearchCategoryScreenState();
}

class _SearchCategoryScreenState extends State<SearchCategoryScreen> {
  final List<Tag> topographic = [
    tags[0],
    tags[1],
    tags[2],
    tags[3],
    tags[4],
    tags[5],
    tags[6],
    tags[7],
  ];

  final List<Tag> activities = [
    tags[8],
    tags[9],
    tags[10],
    tags[11],
    tags[12],
    tags[13],
    tags[14],
  ];

  final List<Tag> seasons = [
    tags[15],
    tags[16],
    tags[17],
    tags[18],
  ];

  final List<Tag> region = [
    tags[19],
    tags[20],
    tags[21],
  ];

  List<Tag> provinces = [
    tags[22],
  ];

  List<Tag> select = []; // Declare a mutable list

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    select = List.from(widget.list);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
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
                        builder: (ctx) => SearchScreen(
                          search: widget.search,
                          list: select,
                        ),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Danh mục",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Miền:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    childAspectRatio:
                        3, // Aspect ratio for the items (1 means square)
                    crossAxisSpacing: 7, // Spacing between columns
                    mainAxisSpacing: 3.h, // Spacing between rows
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: region.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => TagSearchCard(
                    tag: region[index],
                    tags: select,
                    updateTags: updateTags,
                  ),
                ),
              ),
              const SizedBox(
                height: 38,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Tỉnh:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              provinces.length == 1
                  ? Container(
                      margin: const EdgeInsets.only(left: 22),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 items per row
                          childAspectRatio:
                              3, // Aspect ratio for the items (1 means square)
                          crossAxisSpacing: 7, // Spacing between columns
                          mainAxisSpacing: 3.h, // Spacing between rows
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provinces.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => IgnorePointer(
                          child: Opacity(
                            opacity: 0.5,
                            child: TagSearchCard(
                              tag: provinces[index],
                              tags: select,
                              updateTags: updateTags,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(left: 22),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 items per row
                          childAspectRatio:
                              3, // Aspect ratio for the items (1 means square)
                          crossAxisSpacing: 7, // Spacing between columns
                          mainAxisSpacing: 3.h, // Spacing between rows
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provinces.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => TagSearchCard(
                          tag: provinces[index],
                          tags: select,
                          updateTags: updateTags,
                        ),
                      ),
                    ),
              const SizedBox(
                height: 38,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Vị trí:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    childAspectRatio:
                        3, // Aspect ratio for the items (1 means square)
                    crossAxisSpacing: 7, // Spacing between columns
                    mainAxisSpacing: 3.h, // Spacing between rows
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: topographic.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => TagSearchCard(
                    tag: topographic[index],
                    tags: select,
                    updateTags: updateTags,
                  ),
                ),
              ),
              const SizedBox(
                height: 38,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Hoạt động:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    childAspectRatio:
                        3, // Aspect ratio for the items (1 means square)
                    crossAxisSpacing: 7, // Spacing between columns
                    mainAxisSpacing: 3.h, // Spacing between rows
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: activities.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => TagSearchCard(
                    tag: activities[index],
                    tags: select,
                    updateTags: updateTags,
                  ),
                ),
              ),
              const SizedBox(
                height: 38,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Mùa:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    childAspectRatio:
                        3, // Aspect ratio for the items (1 means square)
                    crossAxisSpacing: 7, // Spacing between columns
                    mainAxisSpacing: 3.h, // Spacing between rows
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: seasons.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => TagSearchCard(
                    tag: seasons[index],
                    tags: select,
                    updateTags: updateTags,
                  ),
                ),
              ),
              const SizedBox(
                height: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Callback function to modify the tags list
  void updateTags(Tag tag, bool add) {
    if (add) {
      setState(() {
        select.add(tag);
      });
    } else {
      setState(() {
        select.remove(tag);
      });
    }
  }
}
