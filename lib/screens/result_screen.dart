import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_state.dart';
import '../state/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;

    final (title, accentColor, emoji) = switch (round.winner!) {
      RoundWinner.innocents => (
          'MASUMLAR KAZANDI!',
          Theme.of(context).colorScheme.primary, // Elektrik mavisi
          '🛡️',
        ),
      RoundWinner.spies => (
          'CASUSLAR KAZANDI!',
          Theme.of(context).colorScheme.error, // Fuşya
          '🎭',
        ),
      RoundWinner.whiteCardSolo => (
          'BEYAZ KART KAZANDI!',
          Theme.of(context).colorScheme.secondary, // Neon Sarı
          '⚪',
        ),
    };

    final isWhiteCardSolo = round.winner == RoundWinner.whiteCardSolo;
    final whiteGuesserName = isWhiteCardSolo
        ? provider.players
            .firstWhere((p) => p.id == round.whiteCardGuess?.playerId)
            .name
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('TUR ${round.roundNumber} TAMAMLANDI'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kazanan İlan Kartı
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.bungee(
                        fontSize: 22,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isWhiteCardSolo) ...[
                      const SizedBox(height: 6),
                      Text(
                        '$whiteGuesserName ana kelimeyi tahmin ederek turu tek başına kazandı!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Kelimelerin Açıklanması
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ANA KELİME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            round.wordPair.mainWord,
                            style: GoogleFonts.bungee(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SİYAH KELİME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            round.wordPair.spyWord,
                            style: GoogleFonts.bungee(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'LİDER TABLOSU',
                style: GoogleFonts.bungee(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Sıralı Oyuncu Listesi
              Expanded(
                child: ListView.separated(
                  itemCount: provider.playersByScoreDesc().length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = provider.playersByScoreDesc()[index];
                    final isLeader = index == 0 && p.score > 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLeader
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: isLeader ? 1.5 : 0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isLeader
                                  ? Theme.of(context).colorScheme.secondary
                                  : const Color(0xFF1A1A24),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              isLeader ? '👑' : '${index + 1}',
                              style: TextStyle(
                                fontSize: isLeader ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                color: isLeader ? Colors.black : Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A24),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${p.score} P',
                              style: GoogleFonts.bungee(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Sonraki Tura Geç Butonu (Kullanıcının belirlediği modu koruyarak startNewRound çağrılır)
              Padding(
                padding: const EdgeInsets.only(top: 10),
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
                  onPressed: () {
                    provider.finishRound();
                    provider.startNewRound(); // Setup'ta seçilen modu korur
                  },
                  child: Text(
                    'SONRAKİ TUR',
                    style: GoogleFonts.bungee(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}