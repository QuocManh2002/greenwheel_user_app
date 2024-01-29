import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/comment_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

class AddCommentScreen extends StatelessWidget {
  const AddCommentScreen({super.key, required this.callback, this.comments});
  final List<CommentViewModel>? comments;
  final void Function(String commentText) callback;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _commentController = TextEditingController();
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thêm bình luận'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments!.length > 4 ? 4 : comments!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric( vertical: 10),
                      child: CommentCard(comment: comments![index]),
                    ),
                  ),
                  // SizedBox(height: 2.h,),
                  
                  // SizedBox(
                  //   height: 2.h,
                  // ),
                  // ElevatedButton.icon(
                  //   icon:const Icon(Icons.send),
                  //     style: elevatedButtonStyle,
                  //     onPressed: () {
                  //       if (_formKey.currentState!.validate()) {
                  //         callback(_commentController.text);
                  //         _commentController.clear();
                  //         Navigator.of(context).pop();
                  //       }
                  //     },
                  //     label: const Text('Bình luận'))
                ]),
              ),
            ),
            Row(
              children: [
                Form(
                      key: _formKey,
                      child: SizedBox(
                        width: 80.w,
                        child: TextFormFieldWithLength(
                          controller: _commentController,
                          inputType: TextInputType.text,
                          isAutoFocus: true,
                          hinttext: 'Để lại bình luận của bạn ...',
                          maxline: 3,
                          minline: 1,
                          onValidate: (value) {
                            if (value!.length < 10) {
                              return "Bình luận của bạn phải từ 10 - 120 ký tự";
                            } else if (VNBadwordsFilter.isProfane(value)) {
                              return "Bình luận của bạn chứa từ ngữ không hợp lệ";
                            } else if (!Utils().IsValidSentence(value)) {
                              return "Bình luận của bạn chứa quá nhiều từ ngữ trùng lặp";
                            }
                          },
                        ),
                      )),
                      const Spacer(),
                      IconButton(onPressed: (){}, icon:const Icon(Icons.send, color: primaryColor,size: 30,))

              ],
            )
          ],
        ),
      ),
    ));
  }
}
