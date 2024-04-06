import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:greenwheel_user_app/config/token_generator.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/temp_plan.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer2/sizer2.dart';

class SharePlanScreen extends StatefulWidget {
  const SharePlanScreen(
      {super.key,
      required this.planId,
      required this.planMembers,
      required this.isFromHost,
      required this.joinMethod,
      required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;
  final bool isFromHost;
  final String joinMethod;
  final List<PlanMemberViewModel> planMembers;

  @override
  State<SharePlanScreen> createState() => _SharePlanScreenState();
}

class _SharePlanScreenState extends State<SharePlanScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneSearch.dispose();
  }

  final GlobalKey _qrkey = GlobalKey();
  final TextEditingController phoneSearch = TextEditingController();
  bool _isSearch = false;
  bool _isSearchingLoading = true;
  CustomerViewModel? _customer;
  CustomerService customerService = CustomerService();
  bool _isEmptySearchResult = false;
  bool _isEnableToInvite = true;
  final PlanService _planService = PlanService();
  List<PlanMemberViewModel> _planMembers = [];

  searchCustomer() async {
    CustomerViewModel? customer = await customerService.GetCustomerByPhone(
        '84${phoneSearch.text.substring(1)}');
    if (customer == null) {
      setState(() {
        _isEmptySearchResult = true;
        _isSearchingLoading = false;
      });
    } else {
      if (_planMembers.any((member) => member.accountId == customer.id && (member.status == 'JOINED' || member.status == 'BLOCKED'))) {
        setState(() {
          _isEnableToInvite = false;
        });
      } else {
        setState(() {
          _isEnableToInvite = true;
        });
      }
      setState(() {
        _customer = customer;
        _isEmptySearchResult = false;
        _isSearchingLoading = false;
      });
    }
  }

  Future<Uint8List> convertQRToBytes() async {
    RenderRepaintBoundary boundary =
        _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3);
    final whietPaint = Paint()..color = Colors.white;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawRect(
        Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
        whietPaint);
    canvas.drawImage(image, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  Future<void> onScan() async {
    try {
      final qrCorde = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      if (qrCorde.isNotEmpty) {
        final jwt = JWT.decode(qrCorde);
        if (jwt.payload['planId'] != null) {
          print('Payload for planId!');
        } else {
          print('Payload for travelerId!');
        }
      }
    } on PlatformException {
      print("exception");
    }
  }

  onSend() async {
    Uint8List? pngBytes = await convertQRToBytes();
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(pngBytes);
    await Share.shareXFiles([XFile(path)],
        text:
            "Chào bạn, hi vọng là chúng ta sẽ có khoảng thời gian khám phá thật vui vẻ cùng nhau.");
  }

  onSave() async {
    try {
      Uint8List? uint8list = await convertQRToBytes();
      final result = await ImageGallerySaver.saveImage(uint8list);
      if (result['isSuccess']) {
        Fluttertoast.showToast(
          msg: 'Lưu hình ảnh thành công!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1, // Duration in seconds
        );
        print('Image saved!');
        String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
        sharedPreferences.setString('deviceToken', deviceToken);
        print(deviceToken);
      } else {
        print('Something wrong when saving image!');
        print('${result['error']}');
      }
    } catch (e) {
      print(e);
    }
  }

  onInvite() async {
    var rs = await _planService.inviteToPlan(widget.planId, _customer!.id, context);
    if (rs != 0) {
      AwesomeDialog(
              // ignore: use_build_context_synchronously
              context: context,
              title: 'Đã gửi lời mời',
              dialogType: DialogType.success,
              titleTextStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              btnOkColor: primaryColor,
              btnOkOnPress: () {
                phoneSearch.clear();
                _planMembers.add(PlanMemberViewModel(
                    name: _customer!.name,
                    memberId: _customer!.id,
                    phone: _customer!.phone,
                    accountId: _customer!.id,
                    weight: 1,
                    isMale: _customer!.isMale,
                    status: "INVITED"));
                setState(() {
                  _isSearch = false;
                });
              },
              btnOkText: 'Ok')
          .show();
    }
  }

  setUpData() async {
    var mems = await _planService.getPlanMember(widget.planId, 'JOIN', context);
    if (mems.isNotEmpty) {
      setState(() {
        _planMembers = mems;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const BackButton(
          style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
        ),
        title: const Text(
          "Chia sẻ kế hoạch",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
                onPressed: onScan,
                icon: const Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 35,
                  color: Colors.white,
                )),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: TextField(
                cursorColor: primaryColor,
                controller: phoneSearch,
                onChanged: (value) {
                  setState(() {
                    _isSearch = true;
                  });
                  if (value.length == 10) {
                    searchCustomer();
                  } else {
                    _isSearchingLoading = true;
                  }
                  if (value.isEmpty) {
                    setState(() {
                      _isSearch = false;
                    });
                  }
                },
                style: const TextStyle(fontSize: 18),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Tìm số điện thoại",
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide(color: primaryColor, width: 1.8)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide(color: primaryColor)),
                ),
              ),
            ),
            if (widget.joinMethod == 'SCAN')
              Column(
                children: [
                  SizedBox(
                    height: 3.h,
                  ),
                  RepaintBoundary(
                    key: _qrkey,
                    child: QrImageView(
                      data: TokenGenerator.generateToken(
                          TempPlan(
                            isFromHost: widget.isFromHost,
                            planId: widget.planId,
                            isEnableToJoin: widget.isEnableToJoin,
                          ),
                          "plan"),
                      version: QrVersions.auto,
                      size: 80.w,
                      gapless: true,
                      errorStateBuilder: (context, error) {
                        return const Text(
                          "Something went wrong! please try again!",
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton.icon(
                                style: elevatedButtonStyle.copyWith(
                                    minimumSize: const MaterialStatePropertyAll(
                                        Size(0, 50))),
                                onPressed: onSave,
                                icon: const Icon(Icons.file_download_outlined),
                                label: const Text("Tải xuống"))),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                            child: ElevatedButton.icon(
                                style: elevatedButtonStyleNoSize.copyWith(
                                    minimumSize: const MaterialStatePropertyAll(
                                        Size(0, 50))),
                                onPressed: onSend,
                                icon: const Icon(Icons.share),
                                label: const Text("Gửi mã")))
                      ],
                    ),
                  )
                ],
              ),
          ]),
          if (_isSearch)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 13.h),
              child: Container(
                height: 13.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black12,
                      offset: Offset(2, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          "Kết quả tìm kiếm",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    _isSearchingLoading
                        ? Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: primaryColor,
                            ))
                        : _isEmptySearchResult
                            ? const Expanded(
                                child: Center(
                                  child: Text(
                                    'Không tìm thấy thông tin người dùng',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Container(
                                    height: 6.h,
                                    width: 6.h,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    clipBehavior: Clip.hardEdge,
                                    child: _customer!.avatarUrl == null
                                        ? Image.asset(
                                            _customer!.isMale
                                                ? male_default_avatar
                                                : female_default_avatar,
                                            height: 6.h,
                                            width: 6.h,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            '$baseBucketImage${_customer!.avatarUrl!}',
                                            width: 6.h,
                                            height: 6.h,
                                            fit: BoxFit.cover),
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  SizedBox(
                                    width: 40.w,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _customer!.name,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "0${_customer!.phone.substring(3)}",
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  _isEnableToInvite
                                      ? TextButton(
                                          style: ButtonStyle(
                                              shape:
                                                  const MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  primaryColor),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8)))),
                                              overlayColor:
                                                  MaterialStatePropertyAll(
                                                      primaryColor
                                                          .withOpacity(0.3))),
                                          onPressed: onInvite,
                                          child: const Text(
                                            'Mời',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColor),
                                          ))
                                      : Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                color: primaryColor,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(8),
                                              )),
                                          child: const Text(
                                            'Đã mời',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColor),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 12,
                                  )
                                ],
                              ),
                  ],
                ),
              ),
            )
        ],
      ),
    ));
  }
}
