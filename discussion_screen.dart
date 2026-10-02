import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// DISCUSSION fazı: activeOrder sırasına göre her oyuncu bir ipucu
/// kelime söyler (uygulama ipucunun kendisini kaydetmez — sadece
/// sırayı yönetir, ipucu sözlü olarak masada söylenir).
class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final playerId = provider.engine!.getPlayerAwaitingClue();
    final player = provider.players.firstWhere((p) => p.id == playerId);
    final position = round.activeOrder.indexOf(playerId) + 1;

    return Scaffold(
      appBar: AppBar(title: Text('Tur ${round.roundNumber} • Tartışma')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$position / ${round.activeOrder.length}',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 16),
              const Icon(Icons.record_voice_over, size: 64),
              const SizedBox(height: 16),
              Text(
                '${player.name}, sıra sende!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelimeni doğrudan söylemeden,\nona çağrışım yapan bir ipucu söyle.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => provider.advanceDiscussionTurn(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('İpucunu Söyledim, Sıradaki'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}