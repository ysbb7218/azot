import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'sudoku_board.dart';

class SudokuScreen extends StatefulWidget {
  final int level;

  const SudokuScreen({required this.level, super.key});

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late Sudoku _sudoku;
  late List<List<TextEditingController>> _controllers;
  late List<List<bool>> _invalidCells;
  int userPoints = 0;
  bool isLoading = true;
  int startTime = 0;

  @override
  void initState() {
    super.initState();
    _sudoku = Sudoku(level: widget.level);
    _controllers = List.generate(
      9,
      (_) => List.generate(9, (_) => TextEditingController()),
    );
    _invalidCells = List.generate(9, (_) => List.generate(9, (_) => false));
    _initializeBoard();
    _fetchUserPoints();
    startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  void _initializeBoard() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (_sudoku.board[row][col] != 0) {
          _controllers[row][col].text = _sudoku.board[row][col].toString();
        }
      }
    }
  }

  Future<void> _fetchUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
      return;
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userPoints = snapshot.data()?['points'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puan yüklenemedi: $e',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ).animate().fadeIn(duration: 500.ms),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateCell(int row, int col, String value) {
    if (_sudoku.isCellFixed(row, col)) return;

    int? num = int.tryParse(value);
    setState(() {
      if (num != null && num >= 1 && num <= 9) {
        _sudoku.board[row][col] = num;
        _invalidCells[row][col] = !_sudoku.isValidInput(row, col, num);
        if (_invalidCells[row][col]) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Geçersiz hamle!',
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
        }
      } else {
        _sudoku.board[row][col] = 0;
        _controllers[row][col].text = '';
        _invalidCells[row][col] = false;
      }
    });
  }

  Future<void> _checkCompletion() async {
    if (_sudoku.isSolved()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timeTaken = endTime - startTime;
        final pointsToAdd =
            widget.level * 10; // 10 for Easy, 20 for Medium, 30 for Hard
        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final userDoc = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid);
            final snapshot = await transaction.get(userDoc);
            final currentStats = snapshot.data()?['stats'] ?? {};
            final gamesPlayed = (currentStats['gamesPlayed'] ?? 0) + 1;
            final gamesCompleted = (currentStats['gamesCompleted'] ?? 0) + 1;
            final totalTime = (currentStats['avgTime'] ?? 0) + timeTaken;

            transaction.update(userDoc, {
              'points': FieldValue.increment(pointsToAdd),
              'stats': {
                'gamesPlayed': gamesPlayed,
                'gamesCompleted': gamesCompleted,
                'avgTime': totalTime,
              },
            });

            // Update leaderboard
            await FirebaseFirestore.instance.collection('leaderboard').add({
              'email': user.email,
              'level': widget.level,
              'time': timeTaken,
              'points': pointsToAdd,
              'timestamp': FieldValue.serverTimestamp(),
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tebrikler! Sudoku tamamlandı! +$pointsToAdd puan kazandınız.',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ).animate().fadeIn(duration: 500.ms),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
            ),
          );

          setState(() {
            userPoints += pointsToAdd;
          });

          _newGame();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hata: $e',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sudoku tamamlanmadı veya hatalı!',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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

  void _newGame() {
    setState(() {
      _sudoku = Sudoku(level: widget.level);
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          _controllers[row][col].text = _sudoku.board[row][col] != 0
              ? _sudoku.board[row][col].toString()
              : '';
          _invalidCells[row][col] = false;
        }
      }
      startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    });
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
                  'Oyun yükleniyor...',
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
        title: Text(
          'Sudoku - Seviye ${widget.level}',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _newGame,
            tooltip: 'Yeni Oyun',
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
                        Icon(Icons.star, color: Colors.blue.shade700, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Puanınız: $userPoints',
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
                .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms),
            const SizedBox(height: 24),
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          childAspectRatio: 1,
                        ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      bool isFixed = _sudoku.isCellFixed(row, col);
                      bool isInvalid = _invalidCells[row][col];

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: row % 3 == 0
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade300,
                              width: row % 3 == 0 ? 2 : 1,
                            ),
                            left: BorderSide(
                              color: col % 3 == 0
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade300,
                              width: col % 3 == 0 ? 2 : 1,
                            ),
                            right: BorderSide(
                              color: (col + 1) % 3 == 0
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade300,
                              width: (col + 1) % 3 == 0 ? 2 : 1,
                            ),
                            bottom: BorderSide(
                              color: (row + 1) % 3 == 0
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade300,
                              width: (row + 1) % 3 == 0 ? 2 : 1,
                            ),
                          ),
                          color: isFixed
                              ? Colors.grey.shade200
                              : isInvalid
                              ? Colors.red.shade100
                              : Colors.white,
                        ),
                        child: Center(
                          child: isFixed
                              ? Text(
                                  _sudoku.board[row][col].toString(),
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : TextField(
                                  controller: _controllers[row][col],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  enabled: !isFixed,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) =>
                                      _updateCell(row, col, value),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(
                        duration: 600.ms,
                        delay: (200 + index * 10).ms,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkCompletion,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'Çözümü Kontrol Et',
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
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms),
            const SizedBox(height: 16),
            SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _newGame,
                    icon: Icon(Icons.refresh, color: Colors.red.shade700),
                    label: Text(
                      'Yeni Oyun',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade700),
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
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
