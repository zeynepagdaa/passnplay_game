import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';
import 'game_card.dart';

/// DEALING fazı: Sırayla her oyuncuya telefonu verme ve kartı görüntüleme ekranı.
class DealingScreen extends StatefulWidget {
  const DealingScreen({super.key});

  @override
  State<DealingScreen> createState() => _DealingScreenState();
}

class _DealingScreenState extends State<DealingScreen> {
  bool _isCardVisible = false;
  String? _lastPlayerId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final playerId = provider.engine!.getPlayerAwaitingCardView();

    // Sıradaki oyuncu değiştiğinde kartı otomatik gizle
    if (_lastPlayerId != playerId) {
      _lastPlayerId = playerId;
      _isCardVisible = false;
    }

    final player = provider.players.firstWhere((p) => p.id == playerId);
    final assignment =
        round.assignments.firstWhere((a) => a.playerId == playerId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Üst Tur Bilgi Rozeti
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tur ${round.roundNumber} • Kart Dağıtımı',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Ortadaki Ana Görünüm: Ya Handoff (El Değiştirme) ya da GameCard
              !_isCardVisible
                  ? _buildHandoffView(player.name)
                  : GameCard(
                      playerName: player.name,
                      word: assignment.word,
                      onConfirm: () {
                        provider.confirmCardViewed(playerId);
                        setState(() => _isCardVisible = false);
                      },
                    ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandoffView(String playerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD1DC), // Pastel pembe
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📱', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sıradaki Oyuncu',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            playerName,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Lütfen telefonu $playerName adlı oyuncuya verin.\nDiğer oyuncular ekrana bakmamalıdır.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF95A5A6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB19CD9), // Pastel lila
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: () => setState(() => _isCardVisible = true),
              child: Text(
                'Ben $playerName, Hazırım',
                style: const TextStyle(
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