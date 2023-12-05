import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer2/sizer2.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final CarouselController carouselController = CarouselController();
  int currentImageIndex = 0;
  bool isLoading = true;
  List<dynamic> imageUrls = [];
  List<LocationViewModel>? locationModels;
  String data = 'Quoc Manh';
  final GlobalKey qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/QR_Code';

  // LocationService _locationService = LocationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  onSend() async {
    final urlImage = defaultUserAvatarLink;
    final url = Uri.parse(urlImage);
    final response = await http.get(url);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path)], text: "quoc manh");
  }

  onSave() async {
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Image.network(
            defaultUserAvatarLink,
            height: 30.h,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: onSend,
                  child: Text('Send'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: onSave,
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              style: elevatedButtonStyle.copyWith(
                  minimumSize: MaterialStatePropertyAll(Size(50.w, 45))),
              onPressed: _captureAndSaveQr,
              child: Text("Generate QR")),
        ),
        const SizedBox(
          height: 50,
        ),
        RepaintBoundary(
          key: qrkey,
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 60.w,
            gapless: true,
            errorStateBuilder: (context, error) {
              return const Text(
                "Something went wrong! please try again!",
                textAlign: TextAlign.center,
              );
            },
          ),
        )
      ],
    )));
  }

  Future<void> _captureAndSaveQr() async {
    try {
      RenderRepaintBoundary boundary =
          qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
      String filename = 'qr_code';

      // GallerySaver.saveImage(path)T

      int i = 1;
      while (await File('$externalDir/$filename.png').exists()) {
        filename = 'qr_code_$i';
        i++;
      }

      dirExists = await File(externalDir).exists();
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$filename.png').create();
      await file.writeAsBytes(pngBytes);
      if (!mounted) return;
      const snackbar = SnackBar(content: Text("QR code saved"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      if (!mounted) return;
      print(e);
      const snackbar = SnackBar(content: Text("Something went wrong"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }
}
