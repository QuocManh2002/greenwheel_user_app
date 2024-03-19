import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/helpers/pdf_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  PrintingInfo? printingInfo;
  PlanService _planService = PlanService();
  PlanDetail? _planDetail ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   _init();
  }

  Future<void> _init() async{
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
    sharedPreferences.setInt('plan_id_pdf', 71);
  }

  @override
  Widget build(BuildContext context) {
    
    pw.RichText.debug = true;
    final actions = <PdfPreviewAction>[
      if(!kIsWeb)
      const PdfPreviewAction(icon: Icon(Icons.save), onPressed: saveAsFile)
    ];

    return SafeArea(child: Scaffold(appBar: AppBar(

    ),
    body:const Center(
      child: PdfPreview(
        maxPageWidth: 700,
        actions: [ ],
        onPrinted: showPrintedToast,
        onShared: showSharedToast,
        build: generatePdf,
      )
    ),
    ));
  }
}