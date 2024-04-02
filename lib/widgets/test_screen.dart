import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/helpers/pdf_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_note_surcharge_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
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
    body: Center(
      child: ElevatedButton(onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => 
        CreateNoteSurchargeScreen(location: LocationViewModel(id: 1, description: "", imageUrls: [], name: "name", activities: [], seasons: [], topographic: "", latitude: 0, longitude: 0, address: "", province: ProvinceViewModel(id: 0, name: "name", thumbnailUrl: "thumbnailUrl")), totalService: 0)));
      }, child: Text('to page'))
    ),
    ));
  }
}