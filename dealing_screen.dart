import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_assignment.dart';
import '../state/game_provider.dart';

/// DEALING fazı: her oyuncu sırayla telefonu alır, kartını gizlice görür,
/// onaylar ve telefonu bir sonrakine geçirir.
///
/// KRİTİK: [_CardFace] widget'ı MAIN ve BLACK kartlar için TAMAMEN
/// AYNI şekilde render edilir (sadece `word` metni farklıdır). Siyah
/// Kart sahibinin ekranı, bir masumun ekranından hiçbir şekilde ayırt
/// edilemez olmalıdır. WHITE kartı ayrı bir görsel gösterir — bu, oyunun
/// zaten bildiği bir kural olduğundan (Beyaz Kart'ın kendi ekranı) açık
/// vermez.
class DealingScreen extends StatefulWidget {
  const DealingScreen({super.key});

  @override
  State<DealingScreen> createState() => _DealingScreenState();
}

class _DealingScreenState extends State<DealingScreen> {
  bool _revealed = false;
  String? _lastPlayerId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final playerId = provider.engine!.getPlayerAwaitingCardView();

    if (_lastPlayerId != playerId) {
      _lastPlayerId = playerId;
      _revealed = false;
    }

    final player = provider.players.firstWhere((p) => p.id == playerId);
    final assignment = round.assignments.firstWhere((a) => a.playerId == playerId);

    return Scaffold(
      appBar: AppBar(title: Text('Tur ${round.roundNumber}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _revealed
              ? _CardFace(
                  assignment: assignment,
                  onConfirm: () {
                    provider.confirmCardViewed(playerId);
                    setState(() => _revealed = false);
                  },
                )
              : _PassDevicePrompt(
                  playerName: player.name,
                  onReveal: () => setState(() => _revealed = true),
                ),
        ),
      ),
    );
  }
}

class _PassDevicePrompt extends StatelessWidget {
  final String playerName;
  final VoidCallback onReveal;
  const _PassDevicePrompt({required this.playerName, required this.onReveal});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.phonelink_ring, size: 72),
        const SizedBox(height: 16),
        Text(
          "Telefonu $playerName'a verin",
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Diğer oyuncular ekrana bakmamalı.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: onReveal,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Kartımı Göster'),
          ),
        ),
      ],
    );
  }
}

class _CardFace extends StatelessWidget {
  final CardAssignment assignment;
  final VoidCallback onConfirm;
  const _CardFace({required this.assignment, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isWhite = assignment.cardType == CardType.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 260,
            height: 320,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: isWhite
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help_outline, size: 56),
                      SizedBox(height: 12),
                      Text(
                        'BEYAZ KART',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bu turda kelimen yok.\nDikkatli dinle, ipuçlarından\nkelimeyi çözmeye çalış.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    // NOT: Bu dal hem MAIN hem BLACK için AYNI koddur —
                    // aralarındaki tek fark `assignment.word` metnidir.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('KELİMEN', style: TextStyle(fontSize: 14, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Text(
                        assignment.word ?? '',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onConfirm,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Gördüm, Devam Et'),
          ),
        ),
      ],
    );
  }
}