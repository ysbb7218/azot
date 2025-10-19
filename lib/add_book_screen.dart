import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedFile;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Dosya seçme hatası: $e';
      });
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedFile == null) {
      setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurun ve bir PDF seçin.';
      });
      return;
    }

    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      setState(() {
        _errorMessage = 'Geçerli bir fiyat girin.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Kullanıcı oturumu açık değil.';
        });
        return;
      }

      final bookRef = FirebaseFirestore.instance.collection('books').doc();
      await bookRef.set({
        'title': _titleController.text.trim(),
        'price': price,
      });

      final storageRef = FirebaseStorage.instance.ref(
        'books/${bookRef.id}.pdf',
      );
      await storageRef.putFile(_selectedFile!);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kitap başarıyla eklendi: ${_titleController.text}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ).animate().fadeIn(duration: 500.ms),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      _titleController.clear();
      _priceController.clear();
      setState(() {
        _selectedFile = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kitap ekleme hatası: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yeni Kitap Ekle',
          style: TextStyle(
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                              'Kitap Bilgileri',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.blue.shade900,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            labelText: 'Kitap Başlığı',
                            hintText: 'Örn: Sudoku Ustası',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade700,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade700,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.book,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            labelText: 'Fiyat (Puan)',
                            hintText: 'Örn: 50',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade700,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade700,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.monetization_on,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 100.ms,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: Icon(
                                    _selectedFile == null
                                        ? Icons.upload_file
                                        : Icons.check_circle,
                                    color: _selectedFile == null
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700,
                                  ),
                                  label: Text(
                                    _selectedFile == null
                                        ? 'PDF Seç'
                                        : 'PDF Seçildi',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.blue.shade700,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 32,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedFile != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.red.shade700,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                    tooltip: 'PDF seçimini kaldır',
                                  ),
                                ),
                            ],
                          ),
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 200.ms,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addBook,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_circle),
                            label: const Text(
                              'Kitap Ekle',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ).animate().slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 300.ms,
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 600.ms),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
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
                          'Yükleniyor...',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
