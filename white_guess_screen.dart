import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// Özel Beyaz Kart kuralı: yakalanan Beyaz Kart sahibi, ana kelimeyi
/// tahmin ederse turu TEK BAŞINA kazanır.
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final guesser = provider.players.firstWhere((p) => p.id == round.eliminatedPlayerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Beyaz Kart — Son Şans')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.psychology_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                '${guesser.name}, yakalandın!\nAma ana kelimeyi doğru tahmin edersen '
                'turu TEK BAŞINA kazanırsın.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Ana kelime tahminin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => provider.submitWhiteCardGuess(guesser.id, _controller.text),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Tahminimi Onayla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}