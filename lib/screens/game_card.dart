import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String playerName;
  final String? word;
  final VoidCallback onConfirm;

  const GameCard({
    super.key,
    required this.playerName,
    this.word,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // word null ise Beyaz Kart'tır, değilse kelimenin kendisini gösterir.
    final displayWord = word ?? 'BEYAZ KART';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Pastel krem arka plan
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E5DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$playerName, senin kelimen:',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF7B7B7B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFAEC6CF), // Pastel mavi kelime kutusu
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              displayWord,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Lütfen kelimeni aklında tut ve ekranı kimseye gösterme.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFFFB7B2), // Pastel somon uyarı
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF77DD77), // Pastel yeşil buton
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              onPressed: onConfirm,
              child: const Text(
                'Anladım, Gizle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}