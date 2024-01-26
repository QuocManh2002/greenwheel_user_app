import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/service/notification_service.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

class TestScreen1 extends StatefulWidget {
  const TestScreen1({super.key});

  @override
  State<TestScreen1> createState() => _TestScreen1State();
}

class _TestScreen1State extends State<TestScreen1> {
  final NotificationService _notiService = NotificationService();
  TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isValidSentence(String sentence) {
    List<String> words = sentence.split(' ');
    Map<String, int> wordFrequency = {};

    for (String word in words) {
      wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      if (wordFrequency[word]! >= 3) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                _notiService.showNotification(const RemoteMessage(
                    notification: RemoteNotification(
                        title: 'Thông báo lịch trình',
                        body:
                            'Leader vừa thay đổi một hoạt động trong lịch trình của bạn.')));
              },
              child: const Text('Push noti')),
          const SizedBox(
            height: 16,
          ),
          Form(
              key: _formKey,
              child: defaultTextFormField(
                controller: _commentController,
                inputType: TextInputType.text,
                maxligne: 2,
                text: 'Bình luận',
                onValidate: (value) {
                  if (value!.isEmpty) {
                    return "Bình luận của bạn không được để trống";
                  } else if (VNBadwordsFilter.isProfane(value)) {
                    return "Bình luận của bạn chứa từ ngữ không hợp lệ";
                  } else if (!_isValidSentence(value)) {
                    return "Bình luận của bạn chứa quá nhiều từ ngữ trùng lặp";
                  }
                },
              )),
          SizedBox(
            height: 2.h,
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          padding: const EdgeInsets.all(12),
                          title: 'Bình luận hợp lệ',
                          titleTextStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          btnOkColor: primaryColor,
                          btnOkOnPress: () {},
                          btnOkText: 'Ok')
                      .show();
                }
              },
              child: const Text('Check valid text'))
        ],
      ),
    ));
  }
}
