import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../state/game_provider.dart';
import 'dealing_screen.dart';
import 'discussion_screen.dart';
import 'voting_screen.dart';
import 'reveal_screen.dart';
import 'white_guess_screen.dart';
import 'result_screen.dart';

/// Oyunun "ana yönlendiricisi": her zaman `provider.currentRound.phase`'e
/// bakıp o faza karşılık gelen ekranı gösterir. Hiçbir ekran kendi
/// başına faz geçişi yapmaz — hepsi provider metotlarını çağırır, o da
/// GameEngine'i ilerletir, bu widget da yeniden çizilir.
class GameFlowScreen extends StatelessWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound;

    if (round == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Casus Oyunu')),
        body: Center(
          child: FilledButton(
            onPressed: () => provider.startNewRound(),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('İlk Turu Başlat'),
            ),
          ),
        ),
      );
    }

    switch (round.phase) {
      case RoundPhase.dealing:
        return const DealingScreen();
      case RoundPhase.discussion:
        return const DiscussionScreen();
      case RoundPhase.voting:
        return const VotingScreen();
      case RoundPhase.reveal:
        return const RevealScreen();
      case RoundPhase.whiteGuess:
        return const WhiteGuessScreen();
      case RoundPhase.result:
        return const ResultScreen();
    }
  }
}