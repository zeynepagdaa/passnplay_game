import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/game_provider.dart';

class WhiteGuessScreen extends StatefulWidget {
  const WhiteGuessScreen({super.key});

  @override
  State<WhiteGuessScreen> createState() => _WhiteGuessScreenState();
}

class _WhiteGuessScreenState extends State<WhiteGuessScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitGuess(GameProvider provider, String guesserId) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    provider.submitWhiteCardGuess(guesserId, text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final guesser = provider.players.firstWhere((p) => p.id == round.eliminatedPlayerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BEYAZ KART • SON ŞANS'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${guesser.name}, yakalandın!',
                      style: GoogleFonts.bungee(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ana kelimeyi doğru tahmin edersen turu TEK BAŞINA kazanırsın!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bungee(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tahminini yaz...',
                          hintStyle: TextStyle(color: Colors.white30, fontSize: 16),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _submitGuess(provider, guesser.id),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _submitGuess(provider, guesser.id),
                  child: Text(
                    'TAHMİNİMİ ONAYLA',
                    style: GoogleFonts.bungee(fontSize: 16),
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