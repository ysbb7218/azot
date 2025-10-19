import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sudoku_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'add_book_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.blue.shade50],
            ),
          ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AZOT',
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
              weight: 700,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(
              Icons.leaderboard,
              color: Colors.white,
              size: 28,
              weight: 700,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
            tooltip: 'Liderlik Tablosu',
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 28,
              weight: 700,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Çıkış Yap',
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
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
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
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
                final points = data?['points'] as int? ?? 0;
                final unlockedLevels =
                    (data?['unlockedLevels'] as List<dynamic>?)?.cast<int>() ??
                    [1];
                final role = data?['role'] as String? ?? 'user';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.shade700,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ).animate().scale(
                              duration: 800.ms,
                              curve: Curves.easeOut,
                              delay: 100.ms,
                            ),
                            const SizedBox(height: 16),
                            Text(
                                  'Hoşgeldiniz, ${user.email ?? 'Kullanıcı'}!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.blue.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 200.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 200.ms,
                                ),
                            const SizedBox(height: 8),
                            Text(
                                  'Puanınız: $points',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 300.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 300.ms,
                                ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Hesabım',
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
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 400.ms)
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                        delay: 400.ms,
                                      ),
                            ),
                            if (role == 'admin') ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child:
                                    ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddBookScreen(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.book,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Kitap Ekle',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade700,
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
                                        )
                                        .animate()
                                        .fadeIn(duration: 600.ms, delay: 500.ms)
                                        .slideY(
                                          begin: 0.2,
                                          end: 0,
                                          duration: 600.ms,
                                          delay: 500.ms,
                                        ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const StoreScreen(),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.store,
                                          color: Colors.blue.shade700,
                                        ),
                                        label: Text(
                                          'Mağaza',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue.shade700,
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
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
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  OutlinedButton.icon(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        Text(
                                                          'Başarıyla çıkış yapıldı.',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
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
                                          await Future.delayed(
                                            const Duration(seconds: 3),
                                          );
                                          if (context.mounted) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/login',
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.logout,
                                          color: Colors.red.shade700,
                                        ),
                                        label: Text(
                                          'Çıkış Yap',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.red.shade700,
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
                                      )
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 700.ms)
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                        delay: 700.ms,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLevelButton(
                      context,
                      level: 1,
                      label: 'Kolay (Seviye 1)',
                      enabled: true,
                      icon: Icons.play_circle,
                      delay: 800.ms,
                    ),
                    const SizedBox(height: 16),
                    _buildLevelButton(
                      context,
                      level: 2,
                      label: unlockedLevels.contains(2)
                          ? 'Orta (Seviye 2)'
                          : 'Orta (50 puan gerekli)',
                      enabled: unlockedLevels.contains(2),
                      icon: unlockedLevels.contains(2)
                          ? Icons.play_circle
                          : Icons.lock,
                      delay: 900.ms,
                    ),
                    const SizedBox(height: 16),
                    _buildLevelButton(
                      context,
                      level: 3,
                      label: unlockedLevels.contains(3)
                          ? 'Zor (Seviye 3)'
                          : 'Zor (150 puan gerekli)',
                      enabled: unlockedLevels.contains(3),
                      icon: unlockedLevels.contains(3)
                          ? Icons.play_circle
                          : Icons.lock,
                      delay: 1000.ms,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required int level,
    required String label,
    required bool enabled,
    required IconData icon,
    required Duration delay,
  }) {
    return SizedBox(
          width: double.infinity,
          child: enabled
              ? ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SudokuScreen(level: level),
                      ),
                    );
                  },
                  icon: Icon(icon, color: Colors.white),
                  label: Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
                )
              : OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(icon, color: Colors.grey.shade600),
                  label: Text(
                    label,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: delay);
  }
}
