import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

class RatingClonePlan extends StatefulWidget {
  const RatingClonePlan({super.key});

  @override
  State<RatingClonePlan> createState() => _RatingClonePlanState();
}

class _RatingClonePlanState extends State<RatingClonePlan> {
  num rating = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _ratingController = TextEditingController();
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
      appBar: AppBar(
        title: const Text('Đánh giá kế hoạch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 3.h,),
          Container(
            alignment: Alignment.center,
            child: RatingBar.builder(
              minRating: 0,
              itemBuilder: (ctx, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) => setState(() {
                rating = value;
              }),
            ),
          ),
          SizedBox(height: 2.h,),
          if (rating > 0 && rating < 4)
            Form(
              key: _formKey,
              child: TextFormFieldWithLength(
                controller: _ratingController,
                inputType: TextInputType.text,
                hinttext: 'Để lại góp ý của bạn cho ứng dụng...',
                onValidate: (value) {
                  if (value!.isEmpty) {
                    return "Bình luận của bạn không được để trống";
                  } else if (VNBadwordsFilter.isProfane(value)) {
                    return "Bình luận của bạn chứa từ ngữ không hợp lệ";
                  } else if (!_isValidSentence(value)) {
                    return "Bình luận của bạn chứa quá nhiều từ ngữ trùng lặp";
                  }
                  return null;
                },
              ),
            ),

             SizedBox(height: 2.h,),
             ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: (){
                if(rating > 0 && rating < 4){
                  if(_formKey.currentState!.validate()){
                    _showDialog();
                  }
                }else{
                    _showDialog();
                  }
              }, child:const Text('Thêm đánh giá'))
        ]),
      ),
    ));
  }

  _showDialog() => AwesomeDialog(context: context,
  dialogType: DialogType.success,
  animType: AnimType.leftSlide,
  title: 'Thêm đánh giá thành công',
  titleTextStyle:const TextStyle(
    fontSize: 18, fontWeight: FontWeight.bold
  ),
  btnOkColor: primaryColor,
  btnOkText: 'Ok',
  btnOkOnPress: (){
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => const TabScreen(pageIndex: 1)), (route) => false);
  }
  ).show();
}
