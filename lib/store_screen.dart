import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mağaza',
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
            weight: 700,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Geri',
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
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
                          'Kullanıcı verileri yükleniyor...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists || user == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kullanıcı verileri yüklenemedi. Lütfen tekrar giriş yapın.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ).animate().fadeIn(duration: 500.ms),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade700,
                    duration: const Duration(seconds: 3),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
              });
              return const SizedBox.shrink();
            }

            int points = snapshot.data?.get('points') ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .snapshots(),
              builder: (context, bookSnapshot) {
                if (bookSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
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
                              'Kitaplar yükleniyor...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  );
                }
                final books = bookSnapshot.data?.docs ?? [];

                return ListView(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Puanınız: $points',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 100.ms,
                        ),
                    const SizedBox(height: 24),
                    if (books.isEmpty)
                      Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Mağazada kitap bulunmamaktadır.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 600.ms,
                            delay: 200.ms,
                          ),
                    ...books.asMap().entries.map((entry) {
                      final index = entry.key;
                      final book = entry.value;
                      final bookId = book.id;
                      final title = book['title'] as String;
                      final price = book['price'] as int;

                      return Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  points >= price ? Icons.book : Icons.lock,
                                  color: Colors.blue.shade700,
                                  size: 36,
                                ),
                                title: Semantics(
                                  label: 'Kitap başlığı: $title',
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                                subtitle: Semantics(
                                  label: 'Fiyat: $price puan',
                                  child: Text(
                                    'Fiyat: $price Puan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: points >= price
                                    ? ElevatedButton.icon(
                                        onPressed: () async {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            final userDoc = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(user.uid);
                                            try {
                                              await FirebaseFirestore.instance
                                                  .runTransaction((
                                                    transaction,
                                                  ) async {
                                                    final snapshot =
                                                        await transaction.get(
                                                          userDoc,
                                                        );
                                                    final currentPoints =
                                                        snapshot
                                                            .data()?['points'] ??
                                                        0;
                                                    if (currentPoints >=
                                                        price) {
                                                      transaction.update(userDoc, {
                                                        'points':
                                                            FieldValue.increment(
                                                              -price,
                                                            ),
                                                        'purchasedBooks':
                                                            FieldValue.arrayUnion(
                                                              [bookId],
                                                            ),
                                                      });
                                                    } else {
                                                      throw Exception(
                                                        'Yetersiz puan',
                                                      );
                                                    }
                                                  });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child:
                                                            Text(
                                                              '$title satın alındı!',
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ).animate().fadeIn(
                                                              duration: 500.ms,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.green.shade700,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child:
                                                            Text(
                                                              'Hata: $e',
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ).animate().fadeIn(
                                                              duration: 500.ms,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.book,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Satın Al',
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                      )
                                    : OutlinedButton.icon(
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.lock,
                                          color: Colors.grey.shade600,
                                        ),
                                        label: Text(
                                          'Yetersiz Puan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 32,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        delay: (200 + index * 100).ms,
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
