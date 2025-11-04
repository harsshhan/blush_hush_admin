import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../constants/styles.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;

  const PdfViewerScreen({super.key, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    downloadAndDisplayPdf();
  }

  Future<void> downloadAndDisplayPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final dir = await getTemporaryDirectory();
      final fileName = widget.url.split('/').last;
      final filePath = '${dir.path}/$fileName.pdf';

      // Download the PDF
      await Dio().download(widget.url, filePath);

      setState(() {
        localFilePath = filePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Styles.backgroundColor,
        title: const Text("Document Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: downloadAndDisplayPdf,
          ),
        ],
      ),
      body: Container(
        color: Styles.backgroundColor,
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading PDF...'),
                  ],
                ),
              )
            : errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: downloadAndDisplayPdf,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : PDFView(
                filePath: localFilePath!,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: 0,
                fitPolicy: FitPolicy.BOTH,
                onRender: (pages) {
                  print('PDF rendered with $pages pages');
                },
                onError: (error) {
                  print('PDF error: $error');
                  setState(() {
                    errorMessage = error.toString();
                  });
                },
              ),
      ),
    );
  }
}
