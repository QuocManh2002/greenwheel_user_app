import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/comment_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/rating_bar.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer2/sizer2.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

class AddCommentScreen extends StatefulWidget {
  const AddCommentScreen({super.key, required this.callback, this.comments, required this.destinationId, required this.location});
  final List<CommentViewModel>? comments;
  final int destinationId;
  final void Function() callback;
  final LocationViewModel location;

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _commentController = TextEditingController();
    LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 25.w,
                        width: 25.w,
                        clipBehavior: Clip.hardEdge,
                        decoration:const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),

                        ),
                        child: Image.network(
                          widget.location.imageUrls[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 2.h),
                      SizedBox(
                        width: 60.w,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.location.name,
                              overflow: TextOverflow.clip,
                              style:const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingBar(rating: 4),
                            ReadMoreText(
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
                                  )
                          ],
                        ),
                      )
                    ],
                  )

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
                          hinttext: 'Để lại bình luận, góp ý của bạn cho địa điểm này...',
                          maxline: 3,
                          minline: 3,
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
                      IconButton(onPressed: ()async{
                        final rs = await _locationService.commentOnDestination(_commentController.text, widget.destinationId);
                        if(rs){
                          widget.callback();
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      }, icon:const Icon(Icons.send, color: primaryColor,size: 30,))

              ],
            )
          ],
        ),
      ),
    ));
  }
}
