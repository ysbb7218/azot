import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'book_viewer_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
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
                          'Profil yükleniyor...',
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

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final points = data?['points'] ?? 0;
            final purchasedBooks =
                data?['purchasedBooks'] as List<dynamic>? ?? [];
            final stats = data?['stats'] as Map<String, dynamic>? ?? {};
            final gamesPlayed = stats['gamesPlayed'] ?? 0;
            final gamesCompleted = stats['gamesCompleted'] ?? 0;
            final avgTime = stats['avgTime'] ?? 0;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Semantics(
                              label: 'Kullanıcı e-posta',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'E-posta: ${user.email ?? 'Bilinmiyor'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
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
                        const SizedBox(height: 16),
                        Semantics(
                              label: 'Puan bilgisi',
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
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 200.ms,
                            ),
                        const SizedBox(height: 16),
                        Semantics(
                              label: 'Oynanan oyunlar',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.gamepad,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Oynanan Oyunlar: $gamesPlayed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 300.ms,
                            ),
                        const SizedBox(height: 16),
                        Semantics(
                              label: 'Tamamlanan oyunlar',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tamamlanan Oyunlar: $gamesCompleted',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 400.ms,
                            ),
                        const SizedBox(height: 16),
                        Semantics(
                              label: 'Ortalama süre',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ortalama Süre: ${(avgTime / (gamesCompleted == 0 ? 1 : gamesCompleted)).toStringAsFixed(1)} sn',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 500.ms,
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                      label: 'Satın alınan kitaplar başlığı',
                      child: Text(
                        'Satın Alınan Kitaplar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      delay: 600.ms,
                    ),
                const SizedBox(height: 16),
                purchasedBooks.isEmpty
                    ? Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Henüz kitap satın alınmadı.',
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
                          .fadeIn(duration: 600.ms, delay: 700.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 600.ms,
                            delay: 700.ms,
                          )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('books')
                            .where(
                              FieldPath.documentId,
                              whereIn: purchasedBooks,
                            )
                            .snapshots(),
                        builder: (context, bookSnapshot) {
                          if (bookSnapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                      ),
                                ],
                              ),
                            );
                          }
                          final books = bookSnapshot.data?.docs ?? [];
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final book = books[index];
                              return Card(
                                elevation: 10,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          Icons.book,
                                          color: Colors.blue.shade700,
                                          size: 36,
                                        ),
                                        title: Semantics(
                                          label:
                                              'Kitap başlığı: ${book['title']}',
                                          child: Text(
                                            book['title'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                        subtitle: Semantics(
                                          label: 'Fiyat: ${book['price']} puan',
                                          child: Text(
                                            'Fiyat: ${book['price']} puan',
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
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookViewerScreen(
                                                      bookId: book.id,
                                                      bookTitle: book['title'],
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Görüntüle',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 32,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 5,
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
                                delay: (700 + index * 100).ms,
                              );
                            },
                          );
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
