import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../state/game_provider.dart';
import '../engine/spy_distribution.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;

    // Kazanan durumuna göre metinler, pastel renkler ve emojiler
    final (title, bannerColor, badgeColor, emoji) = switch (round.winner!) {
      RoundWinner.innocents => (
          'Masumlar Kazandı!',
          const Color(0xFFE8F5E9), // Pastel açık yeşil
          const Color(0xFF77DD77), // Pastel yeşil
          '🕵️️',
        ),
      RoundWinner.spies => (
          'Casuslar Kazandı!',
          const Color(0xFFFFEBEE), // Pastel açık kırmızı
          const Color(0xFFFFB7B2), // Pastel somon
          '🎭',
        ),
      RoundWinner.whiteCardSolo => (
          'Beyaz Kart Kazandı!',
          const Color(0xFFEDE7F6), // Pastel açık mor
          const Color(0xFFB19CD9), // Pastel lila
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
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Tur Başlığı Rozeti
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tur ${round.roundNumber} Tamamlandı',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Kazanan İlan Kartı (Banner)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isWhiteCardSolo) ...[
                      const SizedBox(height: 6),
                      Text(
                        '$whiteGuesserName ana kelimeyi doğru tahmin ederek turu tek başına kazandı!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6A5ACD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Turun Kelimeleri Karşılaştırma Kutusu
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E5DF)),
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF95A5A6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            round.wordPair.mainWord,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0xFFE8E5DF),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SİYAH KELİME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF95A5A6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            round.wordPair.spyWord,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Skor Tablosu Başlığı
              const Text(
                'Lider Tablosu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),

              // Sıralı Oyuncu Listesi (Skora göre azalan)
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
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLeader
                              ? const Color(0xFFAEC6CF)
                              : const Color(0xFFE8E5DF),
                          width: isLeader ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Sıralama Numarası veya Kupa
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isLeader
                                  ? const Color(0xFFFFD1DC) // Lider için pastel pembe
                                  : const Color(0xFFE8E5DF).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              isLeader ? '👑' : '${index + 1}',
                              style: TextStyle(
                                fontSize: isLeader ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A3E72),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Oyuncu Adı
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),

                          // Puan Rozeti
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F0EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${p.score} P',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Sonraki Tura Geç Butonu
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77DD77), // Pastel yeşil
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    provider.finishRound();
                    provider.startNewRound(preference: SpyModePreference.random);
                  },
                  child: const Text(
                    'Sonraki Tur',
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
        ),
      ),
    );
  }
}