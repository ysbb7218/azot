import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class BookViewerScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const BookViewerScreen({
    required this.bookId,
    required this.bookTitle,
    super.key,
  });

  @override
  _BookViewerScreenState createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  String? _pdfPath;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    try {
      final ref = FirebaseStorage.instance.ref('books/${widget.bookId}.pdf');
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${widget.bookId}.pdf');
      await file.writeAsBytes(bytes);
      setState(() {
        _pdfPath = file.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PDF yüklenemedi: $e',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ).animate().fadeIn(duration: 500.ms),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
        actions: [
          if (_pdfPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Sayfa ${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: _pdfPath == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                          'PDF Yükleniyor...',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              )
            : Stack(
                children: [
                  PDFView(
                    filePath: _pdfPath!,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: false,
                    pageFling: true,
                    onPageChanged: (page, total) {
                      setState(() {
                        _currentPage = page!;
                        _totalPages = total!;
                      });
                    },
                    onViewCreated: (controller) {
                      setState(() {
                        _pdfController = controller;
                      });
                    },
                  ).animate().fadeIn(duration: 600.ms),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingActionButton(
                          onPressed: _currentPage > 0
                              ? () async {
                                  await _pdfController?.setPage(
                                    _currentPage - 1,
                                  );
                                  setState(() {
                                    _currentPage = _currentPage - 1;
                                  });
                                }
                              : null,
                          mini: true,
                          backgroundColor: _currentPage > 0
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.arrow_left),
                          tooltip: 'Önceki sayfa',
                          elevation: _currentPage > 0 ? 5 : 0,
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                        ),
                        FloatingActionButton(
                          onPressed: _currentPage < _totalPages - 1
                              ? () async {
                                  await _pdfController?.setPage(
                                    _currentPage + 1,
                                  );
                                  setState(() {
                                    _currentPage = _currentPage + 1;
                                  });
                                }
                              : null,
                          mini: true,
                          backgroundColor: _currentPage < _totalPages - 1
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.arrow_right),
                          tooltip: 'Sonraki sayfa',
                          elevation: _currentPage < _totalPages - 1 ? 5 : 0,
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
