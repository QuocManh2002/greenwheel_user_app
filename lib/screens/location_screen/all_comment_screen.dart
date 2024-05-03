import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/loading_screen/all_comments_loading_screen.dart';
import 'package:greenwheel_user_app/screens/location_screen/add_comment_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/comment_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class AllCommentScreen extends StatefulWidget {
  const AllCommentScreen(
      {super.key,
      required this.destinationId,
      required this.destinationDescription,
      required this.destinationImageUrl,
      required this.callback,
      required this.destinationName});
  final int destinationId;
  final String destinationDescription;
  final String destinationImageUrl;
  final String destinationName;
  final void Function(bool isFromQuery, int _numberOfComment) callback;

  @override
  State<AllCommentScreen> createState() => _AllCommentScreenState();
}

class _AllCommentScreenState extends State<AllCommentScreen> {
  LocationService _locationService = LocationService();
  List<CommentViewModel> commentList = [];
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    final rs = await _locationService.getComments(widget.destinationId);
    if (rs != null) {
      rs.sort((a, b) => b.date.compareTo(a.date),);
      setState(() {
        commentList = rs;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Tất cả bình luận'),
            leading: BackButton(
              onPressed: () {
                widget.callback(false, commentList.length);
                Navigator.of(context).pop();
              },
            ),
          ),
          body: isLoading
              ? const AllCommentsLoadingScreen()
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: SizedBox(
                          height: 70.h,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: commentList.length,
                              itemBuilder: (ctx, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: CommentCard(
                                        isViewAll: true,
                                        comment: commentList[index]),
                                  )),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          style: elevatedButtonStyle,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => AddCommentScreen(
                                      destinationDescription:
                                          widget.destinationDescription,
                                      destinationId: widget.destinationId,
                                      callback: setUpData,
                                      destinationImageUrl:
                                          widget.destinationImageUrl,
                                      destinationName: widget.destinationName,
                                    )));
                          },
                          label: const Text('Thêm bình luận')),
                      SizedBox(
                        height: 1.h,
                      )
                    ],
                  ),
                )),
    );
  }
}
