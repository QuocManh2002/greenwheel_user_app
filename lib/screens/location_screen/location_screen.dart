import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/select_default_address.dart';
import 'package:greenwheel_user_app/screens/location_screen/add_comment_screen.dart';
import 'package:greenwheel_user_app/screens/location_screen/all_comment_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/suggest_plan_by_location.dart';
import 'package:greenwheel_user_app/screens/sub_screen/local_map_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/comment_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/rating_bar.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/tag.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.locationId});
  final int locationId;

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
  List<CommentViewModel> _comments = [];
  LocationService _locationService = LocationService();
  LocationViewModel? location;

  var default_address = sharedPreferences.getString('defaultAddress');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    location = await _locationService.GetLocationById(widget.locationId);
    if (location != null) {
      imageUrls = location!.imageUrls;
      _comments = location!.comments!;
      // province tag
      tagList.add(getTag(location!.topographic));
      for (final activity in location!.activities) {
        tagList.add(getTag(activity));
      }
      for (final season in location!.seasons) {
        tagList.add(getTag(season));
      }
      setState(() {
        lineNumber = (tagList.length / 4).ceil();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
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
                                          .map((item) => CachedNetworkImage(
                                                key: UniqueKey(),
                                                height: 25.h,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Image.memory(
                                                        kTransparentImage),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.network(
                                                  'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                                                  height: 25.h,
                                                  fit: BoxFit.cover,
                                                ),
                                                imageUrl: '$baseBucketImage$item',
                                              ))
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 20),
                                child: Text(
                                  location!.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, top: 12, bottom: 16),
                                child: Row(
                                  children: [
                                    RatingBar(rating: 5),
                                    const Text(' ${12} đánh giá')
                                  ],
                                ),
                              ),
                              buildDivider(),
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
                                  padding: const EdgeInsets.only(
                                    left: 18,
                                    right: 18,
                                    bottom: 16,
                                  ),
                                  child: ReadMoreText(
                                    location!.description,
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
                              buildDivider(),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                SuggestPlansByLocationScreen(
                                                    location: location!)));
                                  },
                                  icon: const Icon(Icons.luggage),
                                  label: const Text(
                                    "Tham khảo kế hoạch",
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
                              buildDivider(),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Text(
                                  "Hướng dẫn di chuyển",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (default_address == null) {
                                      AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.warning,
                                              animType: AnimType.leftSlide,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              title:
                                                  'Không tìm thấy địa chỉ mặc định',
                                              titleTextStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              desc:
                                                  'Bạn phải thêm địa chỉ mặc định để xem được bản đồ định hướng. Bạn có muốn thêm địa chỉ mặc định không?',
                                              descTextStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54),
                                              btnOkColor: Colors.blue,
                                              btnOkText: 'Có',
                                              btnOkOnPress: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            SelectDefaultAddress(
                                                                callback:
                                                                    callbackSelectDefaultLocation)));
                                              },
                                              btnCancelColor: Colors.orange,
                                              btnCancelText: 'Không',
                                              btnCancelOnPress: () {})
                                          .show();
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) => LocalMapScreen(
                                                  location: location!)));
                                    }
                                  },
                                  icon: default_address == null
                                      ? Icon(
                                          Icons.warning,
                                          color: Colors.red.withOpacity(0.5),
                                        )
                                      : const Icon(Icons.map),
                                  label: const Text(
                                    "Bản đồ định hướng",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: elevatedButtonStyle.copyWith(
                                      backgroundColor: MaterialStatePropertyAll(
                                          default_address == null
                                              ? Colors.grey.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.6)),
                                      foregroundColor: MaterialStatePropertyAll(
                                          default_address == null
                                              ? Colors.grey
                                              : Colors.black)),
                                ),
                              ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(vertical: 16),
                              //   child: Container(
                              //     alignment: Alignment.center,
                              //     child: ElevatedButton.icon(
                              //       onPressed: () {},
                              //       icon: const Icon(Icons.menu_book),
                              //       label: const Text(
                              //         "Hướng dẫn cộng đồng",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //       style: elevatedButtonStyle.copyWith(
                              //           backgroundColor:
                              //               MaterialStatePropertyAll(
                              //                   Colors.grey.withOpacity(0.6)),
                              //           foregroundColor:
                              //               const MaterialStatePropertyAll(
                              //                   Colors.black)),
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                height: 2.h,
                              ),
                              buildDivider(),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Text(
                                  "Bình luận",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Đánh giá địa điểm',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: RatingBar(rating: 5),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              const Text(
                                                '5/5',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                  '(${location!.comments!.length} đánh giá)')
                                            ],
                                          ),
                                        ]),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      AllCommentScreen(
                                                        destinationId:
                                                            location!.id,
                                                        destinationDescription:
                                                            location!
                                                                .description,
                                                        destinationImageUrl:
                                                            location!
                                                                .imageUrls[0],
                                                        destinationName:
                                                            location!.name,
                                                      )));
                                        },
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Xem tất cả',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: primaryColor),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_right,
                                              color: primaryColor,
                                              size: 23,
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    _comments.length > 2 ? 2 : _comments.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: CommentCard(
                                      comment:
                                          _comments.reversed.elementAt(index)),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: primaryColor),
                                          foregroundColor: primaryColor,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              side: BorderSide(
                                                  color: primaryColor))),
                                      icon: const Icon(Icons.comment),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    AddCommentScreen(
                                                      destinationDescription:
                                                          location!.description,
                                                      destinationImageUrl:
                                                          location!
                                                              .imageUrls[0],
                                                      destinationId:
                                                          location!.id,
                                                      destinationName:
                                                          location!.name,
                                                      callback:
                                                          callbackAddComment,
                                                      comments: _comments,
                                                    )));
                                      },
                                      label: const Text(
                                        'Thêm bình luận',
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 4.h,
                              )
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
                                  String? locationName = sharedPreferences
                                      .getString('plan_location_name');
                                  if (locationName != null) {
                                    AwesomeDialog(
                                      context: context,
                                      animType: AnimType.leftSlide,
                                      dialogType: DialogType.question,
                                      title:
                                          'Bạn đang có bản nháp chuyến đi tại ${locationName == location!.name ? 'địa điểm này' : locationName}',
                                      titleTextStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NotoSans'),
                                      desc:
                                          'Bạn có muốn ghi đè chuyến đi đó không ?',
                                      descTextStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontFamily: 'NotoSans'),
                                      btnOkOnPress: () async {
                                        Utils().clearPlanSharePref();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    CreateNewPlanScreen(
                                                        location: location!,
                                                        isCreate: true)));
                                      },
                                      btnOkColor: Colors.deepOrangeAccent,
                                      btnOkText: 'Có',
                                      btnCancelText: 'Không',
                                      btnCancelColor: Colors.blue,
                                      btnCancelOnPress: () {
                                        if (locationName == location!.name) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      CreateNewPlanScreen(
                                                          location: location!,
                                                          isCreate: true)));
                                        }
                                      },
                                    ).show();
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                CreateNewPlanScreen(
                                                  location: location!,
                                                  isCreate: true,
                                                )));
                                  }
                                },
                                style: elevatedButtonStyle,
                                child: const Text(
                                  "Lên kế hoạch",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      ),
                    ],
                  )));
  }

  Widget buildDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          height: 1.8,
          color: Colors.grey.withOpacity(0.4),
        ),
      );

  callbackSelectDefaultLocation(SearchStartLocationResult? selectedAddress,
      PointLatLng? selectedLatLng) async {
    if (selectedAddress != null) {
      setState(() {
        default_address = selectedAddress.address;
      });
    } else {
      var result = await getPlaceDetail(selectedLatLng!);
      if (result != null) {
        setState(() {
          default_address = result['results'][0]['formatted_address'];
        });
      }
    }
    Utils().SaveDefaultAddressToSharedPref(
        default_address!,
        selectedAddress == null
            ? selectedLatLng!
            : PointLatLng(selectedAddress.lat, selectedAddress.lng));
  }

  callbackAddComment() async {
    var comments = await _locationService.getComments(location!.id);
    setState(() {
      _comments = comments;
    });
  }
}
