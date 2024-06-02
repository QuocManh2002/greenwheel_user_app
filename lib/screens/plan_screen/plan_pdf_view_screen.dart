
import 'package:flutter/material.dart';
import 'package:phuot_app/helpers/pdf_handler.dart';
import 'package:printing/printing.dart';

class PlanPdfViewScreen extends StatefulWidget {
  const PlanPdfViewScreen({super.key});

  @override
  State<PlanPdfViewScreen> createState() => _PlanPdfViewScreenState();
}

class _PlanPdfViewScreenState extends State<PlanPdfViewScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chia sẻ kế hoạch'),
      ),
      body: const Center(
        child: PdfPreview(
            maxPageWidth: 700,
            actions: [],
            onPrinted: showPrintedToast,
            onShared: showSharedToast,
            build: generatePdf),
      ),
    ));
  }
}
