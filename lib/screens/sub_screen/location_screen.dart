
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/comments.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/sub_screen/local_map_screen.dart';
import 'package:greenwheel_user_app/screens/sub_screen/select_date_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/comment_card.dart';
import 'package:greenwheel_user_app/widgets/emergency.dart';
import 'package:greenwheel_user_app/widgets/rating_bar.dart';
import 'package:greenwheel_user_app/widgets/tag.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int lineNumber = 0;
  final CarouselController carouselController = CarouselController();
  int currentImageIndex = 0;
  bool isLoading = true;
  List<dynamic> imageUrls = [];
  List<Tag> tagList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() {
    imageUrls = widget.location.imageUrls;
    // province tag
    tagList.add(getTag(widget.location.topographic));
    for (final activity in widget.location.activities) {
      tagList.add(getTag(activity));
    }
    for (final season in widget.location.seasons) {
      tagList.add(getTag(season));
    }
    setState(() {
      lineNumber = (tagList.length / 4).ceil();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: isLoading
                ? const Center(
                    child: Text("Loading..."),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CarouselSlider(
                                      items: imageUrls
                                          .map(
                                            (item) => Hero(
                                                tag: widget.location.id,
                                                child: FadeInImage(
                                                  // height: 20.h,
                                                  placeholder: MemoryImage(
                                                      kTransparentImage),
                                                  image: NetworkImage(
                                                      item.toString()),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )),
                                          )
                                          .toList(),
                                      carouselController: carouselController,
                                      options: CarouselOptions(
                                        scrollPhysics:
                                            const BouncingScrollPhysics(),
                                        autoPlay: true,
                                        aspectRatio: 2,
                                        autoPlayAnimationDuration:
                                            const Duration(seconds: 3),
                                        autoPlayInterval:
                                            const Duration(seconds: 5),
                                        viewportFraction: 1,
                                        onPageChanged: (index, reason) {
                                          currentImageIndex = index;
                                        },
                                      )),
                                  Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, left: 4),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder()),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              height: 5.h,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(backIcon),
                                              ),
                                            )),
                                      ))
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  widget.location.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Row(
                                  children: [
                                    RatingBar(rating: 5),
                                    Text(' ${12} đánh giá')
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                height: (lineNumber * 5).toDouble().h,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: GridView(
                                    // padding: const EdgeInsets.symmetric(horizontal: 12),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 5 / 2),
                                    children: [
                                      for (var item in tagList)
                                        TagWidget(tag: item)
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: ReadMoreText(
                                    widget.location.description,
                                    trimLines: 3,
                                    textAlign: TextAlign.justify,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: "Xem thêm",
                                    trimExpandedText: "Thu gọn",
                                    lessStyle: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                    moreStyle: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "Hướng dẫn di chuyển",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => LocalMapScreen(
                                                location: widget.location)));
                                  },
                                  icon: const Icon(Icons.map),
                                  label: const Text(
                                    "Bản đồ định hướng",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: elevatedButtonStyle.copyWith(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.grey.withOpacity(0.6)),
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black)),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.menu_book),
                                  label: const Text(
                                    "Hướng dẫn cộng đồng",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: elevatedButtonStyle.copyWith(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.grey.withOpacity(0.6)),
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black)),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "Khẩn cấp",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Emergency(location: widget.location),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "Các loại dịch vụ",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ServiceMainScreen(
                                          startDate: DateTime.now(),
                                          endDate: DateTime.now(),
                                          numberOfMember: 0,
                                          serviceType: services[1],
                                          location: widget.location,
                                          callbackFunction: (List<OrderCreatePlan> orderList){},
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.bed),
                                  label: const Text("Lưu trú"),
                                  style: outlinedButtonStyle.copyWith(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black),
                                      alignment: Alignment.centerLeft),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ServiceMainScreen(
                                          startDate: DateTime.now(),
                                          endDate: DateTime.now(),
                                          numberOfMember: 0,
                                          serviceType: services[0],
                                          location: widget.location,
                                          callbackFunction: (List<OrderCreatePlan> orderList){},
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restaurant),
                                  label: const Text("Ăn uống"),
                                  style: outlinedButtonStyle.copyWith(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black),
                                      alignment: Alignment.centerLeft),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ServiceMainScreen(
                                          startDate: DateTime.now(),
                                          endDate: DateTime.now(),
                                          numberOfMember: 0,
                                          serviceType: services[2],
                                          location: widget.location,
                                          callbackFunction: (List<OrderCreatePlan> orderList){},
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.car_crash),
                                  label: const Text("Đi lại"),
                                  style: outlinedButtonStyle.copyWith(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black),
                                      alignment: Alignment.centerLeft),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ServiceMainScreen(
                                          startDate: DateTime.now(),
                                          endDate: DateTime.now(),
                                          numberOfMember: 0,
                                          serviceType: services[3],
                                          location: widget.location,
                                          callbackFunction: (List<OrderCreatePlan> orderList){},
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.shopping_cart),
                                  label: const Text("Tiện lợi"),
                                  style: outlinedButtonStyle.copyWith(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.black),
                                      alignment: Alignment.centerLeft),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "Đánh giá",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  const Text(
                                    "5",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  RatingBar(rating: 5),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('(${12})')
                                ]),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: CommentCard(comment: comments[index]),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(
                                          color: Colors.black, width: 2)),
                                  child: const Text(
                                    "Xem tất cả đánh giá",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 1.3))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Container(
                            height: 5.h,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => SelectDateScreen(
                                            location: widget.location,
                                            isCreate: true,
                                          )));
                                },
                                style: elevatedButtonStyle,
                                child: const Text(
                                  "Lập kế hoạch",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      ),
                    ],
                  )));
  }
}
