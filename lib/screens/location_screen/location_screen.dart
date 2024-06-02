import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/global_constant.dart';
import '../../core/constants/tags.dart';
import '../../core/constants/urls.dart';
import '../../helpers/goong_request.dart';
import '../../helpers/util.dart';
import '../../main.dart';
import '../../models/tag.dart';
import '../../service/location_service.dart';
import '../../service/traveler_service.dart';
import '../../view_models/customer.dart';
import '../../view_models/location.dart';
import '../../view_models/location_viewmodels/comment.dart';
import '../../view_models/plan_viewmodels/search_start_location_result.dart';
import '../../widgets/plan_screen_widget/comment_card.dart';
import '../../widgets/search_screen_widget/tag.dart';
import '../../widgets/style_widget/button_style.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../authentication_screen/select_default_address.dart';
import '../loading_screen/location_loading_screen.dart';
import '../plan_screen/create_plan/select_start_location_screen.dart';
import '../plan_screen/suggest_plan_by_location.dart';
import '../sub_screen/local_map_screen.dart';
import 'add_comment_screen.dart';
import 'all_comment_screen.dart';

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
  final LocationService _locationService = LocationService();
  final CustomerService _customerService = CustomerService();
  final PlanService _planService = PlanService();
  final Utils util = Utils();
  LocationViewModel? location;
  int? numberOfPublishedPlan = 0;
  int numberOfComment = 0;

  var defaultAddress = sharedPreferences.getString('defaultAddress');
  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    location = await _locationService.getLocationById(widget.locationId);
    numberOfPublishedPlan =
        await _locationService.getNumberOfPublishedPlan(widget.locationId);
    if (location != null && numberOfPublishedPlan != null) {
      imageUrls = location!.imageUrls;
      _comments = location!.comments!;
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
    callbackAddComment();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: isLoading
                ? const LocationLoadingScreen()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                                  defaultHomeImage,
                                                  height: 25.h,
                                                  fit: BoxFit.cover,
                                                ),
                                                imageUrl:
                                                    '$baseBucketImage$item',
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
                                                child: Image.asset(
                                                    GlobalConstant().backIcon),
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
                                    left: 12, bottom: 10, top: 6),
                                child: RatingBar.builder(
                                  initialRating: location!.rating == null
                                      ? 0
                                      : location!.rating!.toDouble(),
                                  itemSize: 20,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star_outline,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (value) {},
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
                              if (numberOfPublishedPlan != null &&
                                  numberOfPublishedPlan! > 0)
                                buildDivider(),
                              if (numberOfPublishedPlan != null &&
                                  numberOfPublishedPlan! > 0)
                                const SizedBox(
                                  height: 16,
                                ),
                              if (numberOfPublishedPlan != null &&
                                  numberOfPublishedPlan! > 0)
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: elevatedButtonStyle.copyWith(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.grey.withOpacity(0.6)),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(
                                          Colors.black,
                                        )),
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
                                    if (defaultAddress == null) {
                                      util.handleNonDefaultAddress(() {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (ctx) => SelectDefaultAddress(
                                                callback:
                                                    callbackSelectDefaultLocation)));
                                      }, context);
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) => LocalMapScreen(
                                                  title: 'Bản đồ định hướng',
                                                  location: location!)));
                                    }
                                  },
                                  icon: defaultAddress == null
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
                                          defaultAddress == null
                                              ? Colors.grey.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.6)),
                                      foregroundColor: MaterialStatePropertyAll(
                                          defaultAddress == null
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
                                              RatingBar.builder(
                                                initialRating:
                                                    location!.rating == null
                                                        ? 0
                                                        : location!.rating!
                                                            .toDouble(),
                                                itemSize: 20,
                                                itemCount: 5,
                                                itemBuilder: (context, index) =>
                                                    const Icon(
                                                  Icons.star_outline,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (value) {},
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                '${location!.rating ?? 0}/5',
                                                style: const TextStyle(
                                                    color: primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                  '($numberOfComment đánh giá)')
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
                                                        callback:
                                                            getNumberOfComment,
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
                                      isViewAll: false,
                                      comment: _comments[index]),
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
                                  if (defaultAddress != null) {
                                    String? locationName = sharedPreferences
                                        .getString('plan_location_name');
                                    if (locationName != null) {
                                      _planService.handleAlreadyDraft(
                                          context,
                                          location!,
                                          locationName,
                                          false,
                                          null, []);
                                    } else {
                                      sharedPreferences.setString(
                                          'plan_location_name', location!.name);
                                      sharedPreferences.setInt(
                                          'plan_location_id', location!.id);
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              child: SelectStartLocationScreen(
                                                isClone: false,
                                                isCreate: true,
                                                location: location!,
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft));
                                    }
                                  } else {
                                    util.handleNonDefaultAddress(
                                        () {}, context);
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
    bool isValid = false;
    if (selectedAddress != null) {
      if (selectedAddress.address.length < 3 ||
          selectedAddress.address.length > 120) {
        handleInvalidAddress();
      } else {
        setState(() {
          defaultAddress = selectedAddress.address;
        });
        isValid = true;
      }
    } else {
      var result = await getPlaceDetail(selectedLatLng!);
      if (result != null) {
        if (result['results'][0]['formatted_address'].length < 3 ||
            result['results'][0]['formatted_address'].length > 120) {
          handleInvalidAddress();
        } else {
          setState(() {
            defaultAddress = result['results'][0]['formatted_address'];
          });
          isValid = true;
        }
      }
    }
    if (isValid) {
      final rs = await _customerService.updateTravelerProfile(CustomerViewModel(
          id: 0,
          name: sharedPreferences.getString('userName')!,
          isMale: sharedPreferences.getBool('userIsMale')!,
          avatarUrl: sharedPreferences.getString('userAvatarUrl'),
          phone: sharedPreferences.getString('userPhone')!,
          balance: 0,
          defaultAddress: defaultAddress,
          defaultCoordinate: selectedAddress != null
              ? PointLatLng(selectedAddress.lat, selectedAddress.lng)
              : selectedLatLng));
      if (rs != null) {
        Utils().saveDefaultAddressToSharedPref(
            defaultAddress!,
            selectedAddress == null
                ? selectedLatLng!
                : PointLatLng(selectedAddress.lat, selectedAddress.lng));
      }
    }
  }

  callbackAddComment() async {
    await getNumberOfComment(true, 0);
    var comments = await _locationService.getComments(location!.id);
    if (comments != null) {
      comments.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _comments = comments;
      });
    }
  }

  handleInvalidAddress() {
    DialogStyle().basicDialog(
        context: context,
        title: 'Độ dài địa chỉ mặc định phải từ 3 - 120 ký tự',
        type: DialogType.warning);
  }

  getNumberOfComment(bool isFromQuery, int numberOfComment) async {
    if (isFromQuery) {
      final rs = await _locationService.getNumberOfComments(
          widget.locationId, context);
      if (rs != null) {
        setState(() {
          numberOfComment = rs;
        });
      }
    } else {
      setState(() {
        numberOfComment = numberOfComment;
      });
    }
  }
}
