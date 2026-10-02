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

    final (title, subtitle) = switch (round.winner!) {
      RoundWinner.innocents => (
          'Masumlar Kazandı! 🕵️',
          'Ana kelime: "${round.wordPair.mainWord}" • Siyah kelime: "${round.wordPair.spyWord}"',
        ),
      RoundWinner.spies => (
          'Casuslar Kazandı! 🎭',
          'Ana kelime: "${round.wordPair.mainWord}" • Siyah kelime: "${round.wordPair.spyWord}"',
        ),
      RoundWinner.whiteCardSolo => (
          'Beyaz Kart Tek Başına Kazandı! ⚪',
          '${provider.players.firstWhere((p) => p.id == round.whiteCardGuess!.playerId).name} '
              'ana kelimeyi doğru tahmin etti: "${round.wordPair.mainWord}"',
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Tur Sonucu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text('Skor Tablosu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final p in provider.playersByScoreDesc())
                    ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(p.name),
                      trailing: Text('${p.score} puan',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                provider.finishRound();
                provider.startNewRound(preference: SpyModePreference.random);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Sonraki Tur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}