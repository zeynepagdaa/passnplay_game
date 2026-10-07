import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_assignment.dart';
import '../state/game_provider.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final eliminatedId = round.eliminatedPlayerId!;
    final eliminated = provider.players.firstWhere((p) => p.id == eliminatedId);
    final assignment = round.assignments.firstWhere((a) => a.playerId == eliminatedId);

    // Kart tipine göre pastel renkler, etiketler ve açıklamalar
    final (roleTitle, roleDesc, cardBgColor, badgeColor, emoji) = switch (assignment.cardType) {
      CardType.main => (
          'MASUM',
          'Yanlış kişi oylandı! Masum bir oyuncu elendi.',
          const Color(0xFFE8F5E9), // Pastel yumuşak yeşil
          const Color(0xFF77DD77), // Pastel canlı yeşil
          '🛡️',
        ),
      CardType.black => (
          'SİYAH KART (Casus)',
          'Tebrikler! Farklı kelimeye sahip casus açığa çıktı.',
          const Color(0xFFFFEBEE), // Pastel yumuşak kırmızı/pembe
          const Color(0xFFFFB7B2), // Pastel somon
          '🕵️',
        ),
      CardType.white => (
          'BEYAZ KART (Casus)',
          'Kelimesiz casus yakalandı! Şimdi ana kelimeyi tahmin etme hakkı var.',
          const Color(0xFFEDE7F6), // Pastel yumuşak leylak
          const Color(0xFFB19CD9), // Pastel lila
          '⚪',
        ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Proje genelindeki pastel krem zemin
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Üst Tur Bilgi Rozeti
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tur ${round.roundNumber} • Kimlik Açıklanıyor',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Açıklanan Rol Kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emoji / İkon Dairesi
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Elenen Oyuncu İsmi
                    Text(
                      '${eliminated.name} elendi!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Rol Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Durum Açıklama Metni
                    Text(
                      roleDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // İlerleme Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77DD77), // Pastel yeşil buton
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => provider.resolveReveal(),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}