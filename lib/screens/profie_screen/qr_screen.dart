import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer2/sizer2.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {

  final GlobalKey _qrkey = GlobalKey();
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
        print('Image saved!');
      } else {
        print('Something wrong when saving image!');
        print('${result['error']}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('QR của tôi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 35,
                )),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 8.h,
              ),
              RepaintBoundary(
                key: _qrkey,
                child: QrImageView(
                  data: "quoc manh",
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
                            style: elevatedButtonStyleNoSize.copyWith(
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
            ]),
      ),
    ));
  }
}
