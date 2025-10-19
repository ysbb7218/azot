import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liderlik Tablosu',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('leaderboard')
              .orderBy('points', descending: true)
              .limit(50)
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
                          'Liderlik tablosu yükleniyor...',
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
            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Liderlik tablosu yüklenemedi: ${snapshot.error}',
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
              });
              return const SizedBox.shrink();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child:
                        Text(
                              'Liderlik tablosu boş.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 100.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 100.ms,
                            ),
                  ),
                ),
              );
            }

            final entries = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final email = entry['email'] as String;
                final level = entry['level'] as int;
                final time = entry['time'] as int;
                final points = entry['points'] as int;

                // İlk 3 için madalya ikonları
                IconData? rankIcon;
                Color? rankColor;
                if (index == 0) {
                  rankIcon = Icons.emoji_events;
                  rankColor = Colors.amber[600];
                } else if (index == 1) {
                  rankIcon = Icons.emoji_events;
                  rankColor = Colors.grey[500];
                } else if (index == 2) {
                  rankIcon = Icons.emoji_events;
                  rankColor = Colors.brown[400];
                }

                return Card(
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 0.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: rankIcon != null
                          ? Icon(
                              rankIcon,
                              color: rankColor,
                              size: 36,
                            ).animate().scale(
                              duration: 600.ms,
                              delay: (100 + index * 100).ms,
                            )
                          : Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: (100 + index * 100).ms,
                            ),
                      title: Semantics(
                        label: 'Kullanıcı e-posta: $email',
                        child: Text(
                          email,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      subtitle: Semantics(
                        label:
                            'Seviye: $level, Süre: ${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}',
                        child: Text(
                          'Seviye: $level, Süre: ${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: Semantics(
                        label: '$points puan',
                        child: Chip(
                          label: Text(
                            '$points puan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ).animate().slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: (100 + index * 100).ms,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
