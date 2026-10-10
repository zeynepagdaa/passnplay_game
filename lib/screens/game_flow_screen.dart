import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_state.dart';
import '../state/game_provider.dart';
import 'dealing_screen.dart';
import 'discussion_screen.dart';
import 'voting_screen.dart';
import 'reveal_screen.dart';
import 'white_guess_screen.dart';
import 'result_screen.dart';

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
      backgroundColor: const Color(0xFF1A1A24),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.casino_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'OYUN HAZIR!',
                  style: GoogleFonts.bungee(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kelimeler ve roller belirlenmeye hazır.\nİlk turu başlatmak için dokunun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => provider.startNewRound(),
                    child: Text(
                      'İLK TURU BAŞLAT',
                      style: GoogleFonts.bungee(fontSize: 16),
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