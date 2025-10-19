import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShopScreen extends StatelessWidget {
  final int userPoints;

  const ShopScreen({required this.userPoints, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zeka Oyunları Kitapları',
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildShopItem(
              context,
              title: 'Kitap 1: Sudoku Stratejileri',
              price: 100,
              userPoints: userPoints,
              index: 0,
            ),
            const SizedBox(height: 16),
            _buildShopItem(
              context,
              title: 'Kitap 2: Akıl ve Mantık Problemleri',
              price: 150,
              userPoints: userPoints,
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required String title,
    required int price,
    required int userPoints,
    required int index,
  }) {
    final isUnlocked = userPoints >= price;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isUnlocked ? Icons.book : Icons.lock,
                color: Colors.blue.shade700,
                size: 36,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade900,
                ),
              ),
              subtitle: Text(
                'Fiyat: $price Puan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUnlocked
                    ? () {
                        // Kitap satın alma işlemi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$title satın alındı!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ).animate().fadeIn(duration: 500.ms),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade700,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  isUnlocked ? 'Satın Al' : 'Yetersiz Puan',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnlocked
                      ? Colors.blue.shade700
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isUnlocked ? 5 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(
      begin: 0.2,
      end: 0,
      duration: 600.ms,
      delay: (index * 100).ms,
    );
  }
}
