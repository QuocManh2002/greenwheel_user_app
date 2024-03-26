
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:sizer2/sizer2.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key, required this.onCompletePlan});
  final void Function(BuildContext context) onCompletePlan;

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  // final _controller = QuillController.basic();
  final jsonText = sharedPreferences.getString('plan_note');

  HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(jsonText);

    // if (jsonText != null) {
    //   final json = jsonDecode(jsonText!);
    //   _controller.document = Document.fromJson(json);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Thêm ghi chú'),
              leading: BackButton(
                onPressed: () {
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.rightSlide,
                          dialogType: DialogType.warning,
                          title: 'Ghi chú chưa được lưu',
                          titleTextStyle: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          desc: 'Vẫn muốn thoát chứ ?',
                          descTextStyle: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 16,
                              color: Colors.grey),
                          btnOkColor: Colors.amber,
                          btnOkText: 'Thoát',
                          btnOkOnPress: () {
                            Navigator.of(context).pop();
                          },
                          btnCancelColor: Colors.blue,
                          btnCancelOnPress: () {},
                          btnCancelText: 'Không')
                      .show();
                },
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  Expanded(
                    child: HtmlEditor(
                      key: UniqueKey(),
                      controller: controller,
                      otherOptions: OtherOptions(
                        height: 100.h,
                      ),
                      htmlEditorOptions: HtmlEditorOptions(
                        initialText: sharedPreferences.getString('plan_note')
                      ),
                      htmlToolbarOptions: const HtmlToolbarOptions(
                          toolbarType: ToolbarType.nativeGrid), 
                    ),
                  ),
                 
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () async {
                        final rs = await controller.getText();
                        print(rs);
                        sharedPreferences.setString('plan_note', rs);
                        Navigator.of(context).pop();
                        widget.onCompletePlan(context);
                      },
                      child: const Text('Lưu')),
                  const SizedBox(
                    height: 24,
                  )
                ],
              ),
            )));
  }
}
