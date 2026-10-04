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

/// Oyunun ana durum yönlendiricisi (Finite State Router):
/// `provider.currentRound.phase` değerini dinleyerek ilgili ekranı çizer.
/// Ekranlar arası geçişler yumuşak bir sayfa geçiş animasyonu (AnimatedSwitcher) ile sağlanır.
class GameFlowScreen extends StatelessWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound;

    Widget currentScreen;

    if (round == null) {
      currentScreen = const _InitialRoundStartView();
    } else {
      currentScreen = switch (round.phase) {
        RoundPhase.dealing => const DealingScreen(key: ValueKey('dealing')),
        RoundPhase.discussion => const DiscussionScreen(key: ValueKey('discussion')),
        RoundPhase.voting => const VotingScreen(key: ValueKey('voting')),
        RoundPhase.reveal => const RevealScreen(key: ValueKey('reveal')),
        RoundPhase.whiteGuess => const WhiteGuessScreen(key: ValueKey('whiteGuess')),
        RoundPhase.result => const ResultScreen(key: ValueKey('result')),
      };
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Proje genelindeki pastel krem zemin
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: currentScreen,
      ),
    );
  }
}

/// Henüz tur başlamamışsa gösterilen pastel karşılama ve başlatma görünümü.
class _InitialRoundStartView extends StatelessWidget {
  const _InitialRoundStartView();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8E5DF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCD0FF), // Pastel lila
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎲', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Oyun Hazır!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kelimeler ve roller belirlenmeye hazır.\nİlk turu başlatmak için dokunun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77DD77), // Pastel yeşil
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => provider.startNewRound(),
                    child: const Text(
                      'İlk Turu Başlat',
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
      ),
    );
  }
}