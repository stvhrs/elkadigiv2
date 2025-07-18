import 'dart:async';
import 'dart:io';
import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elka/model/emodul_model.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:universal_html/html.dart' as html;

class SubabPdfDetail extends StatefulWidget {
  final EmodulModel path;
  const SubabPdfDetail({super.key, required this.path});

  @override
  State<SubabPdfDetail> createState() => _SubabPdfDetailState();
}

class _SubabPdfDetailState extends State<SubabPdfDetail> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;
  bool _hasError = false;
  Future<void> _downloadAndShare() async {
    try {
      if (kIsWeb) {
        // For web: Download via blob
        final response = await http.get(
          Uri.parse(widget.path.pdfUrl),
        ); // Await the request
        final bytes = response.bodyBytes; // Then access bodyBytes
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${widget.path.namaBuku}.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile/desktop: Use printing package
        final response = await http.get(
          Uri.parse(widget.path.pdfUrl),
        ); // Await the request
        await Printing.sharePdf(
          bytes: response.bodyBytes, // Use the awaited response
          filename: '${widget.path.namaBuku}.pdf',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(Uint8List(0)),
    );
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.path.pdfUrl));
      if (response.statusCode == 200) {
        await _pdfController.loadDocument(
          PdfDocument.openData(response.bodyBytes),
        );
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      setState(() => _hasError = true);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.path.namaBuku)),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Failed to load PDF'))
              : PdfViewPinch(controller: _pdfController),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadAndShare,
        child: Icon(Icons.download),
      ),
    );
  }
}
