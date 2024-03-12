import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key, required this.onCompletePlan});
  final void Function(BuildContext context) onCompletePlan;

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _controller = QuillController.basic();
  final jsonText = sharedPreferences.getString('plan_note');
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(jsonText);

    if (jsonText != null) {
      final json = jsonDecode(jsonText!);
      _controller.document = Document.fromJson(json);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title:const Text('Thêm ghi chú'),
              leading: BackButton(
                onPressed: (){
                  AwesomeDialog(context: context,
                    animType: AnimType.rightSlide,
                    dialogType: DialogType.warning,
                    title: 'Ghi chú chưa được lưu',
                    titleTextStyle:const TextStyle(fontFamily: 'NotoSans', fontSize: 18, fontWeight: FontWeight.bold),
                    desc: 'Vẫn muốn thoát chứ ?',
                    descTextStyle: const TextStyle(fontFamily: 'NotoSans', fontSize: 16, color: Colors.grey),
                    btnOkColor: Colors.amber,
                    btnOkText: 'Thoát',
                    btnOkOnPress: () {
                      Navigator.of(context).pop();
                    },
                    btnCancelColor: Colors.blue,
                    btnCancelOnPress: () {
                      
                    },
                    btnCancelText: 'Không'
                  ).show();
                },
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  // if(jsonText == null)
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: _controller,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('vi'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                          controller: _controller,
                          readOnly: false,
                          customStyles: const DefaultStyles(
                              sizeSmall: TextStyle(fontSize: 25),
                              italic: TextStyle(fontSize: 20),
                              small: TextStyle(fontSize: 20)),
                          sharedConfigurations: const QuillSharedConfigurations(
                            locale: Locale('vi'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        final json =
                            jsonEncode(_controller.document.toDelta().toJson());
                        sharedPreferences.setString('plan_note', json);
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
