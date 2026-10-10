import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isWhiteCard = word == null;
    final displayWord = isWhiteCard ? 'BEYAZ KART' : word!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWhiteCard
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 18,
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
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isWhiteCard
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              displayWord,
              textAlign: TextAlign.center,
              style: GoogleFonts.bungee(
                fontSize: 28,
                color: isWhiteCard
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isWhiteCard
                ? 'Kelimen yok! Çaktırmadan diğerlerini dinle.'
                : 'Kelimeni aklında tut ve ekranı kimseye gösterme.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: onConfirm,
              child: Text(
                'ANLADIM, GİZLE',
                style: GoogleFonts.bungee(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}