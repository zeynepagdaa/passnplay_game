import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// DISCUSSION fazı: activeOrder sırasına göre her oyuncu bir ipucu kelime söyler.
/// Uygulama ipucunu kaydetmez; sadece sırayı ve tur akışını yönetir.
class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final playerId = provider.engine!.getPlayerAwaitingClue();
    final player = provider.players.firstWhere((p) => p.id == playerId);
    
    final currentIndex = round.activeOrder.indexOf(playerId);
    final position = currentIndex + 1;
    final totalPlayers = round.activeOrder.length;
    final isLastPlayer = position == totalPlayers;
    final isFirstPlayer = position == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Üst Bilgi Barı (Tur & Sıra Rozeti)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5DF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tur ${round.roundNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEC6CF).withOpacity(0.35), // Pastel mavi rozet
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$position / $totalPlayers',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Ana Kart Alanı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8E5DF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mikrofon / Konuşma İkonu (Pastel lila arka plan)
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCD0FF), // Pastel lila
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎙️', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // İlk konuşmacı vurgusu (2. turdan itibaren en düşük skora sahip olan)
                    if (isFirstPlayer && round.roundNumber > 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD1DC), // Pastel pembe
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'En Düşük Skor • İlk Konuşmacı',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C5363),
                          ),
                        ),
                      ),
                    ],

                    Text(
                      '${player.name}, sıra sende!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kelimeni doğrudan söylemeden,\nona çağrışım yapan tek bir ipucu söyle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
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
                    backgroundColor: isLastPlayer 
                        ? const Color(0xFFFFB7B2) // Pastel somon (Oylamaya geçiş vurgusu)
                        : const Color(0xFF77DD77), // Pastel yeşil
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => provider.advanceDiscussionTurn(),
                  child: Text(
                    isLastPlayer ? 'Herkes Konuştu • Oylamaya Geç' : 'İpucumu Söyledim, Sıradaki',
                    style: const TextStyle(
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