import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_assignment.dart';
import '../state/game_provider.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final eliminatedId = round.eliminatedPlayerId!;
    final eliminated = provider.players.firstWhere((p) => p.id == eliminatedId);
    final assignment = round.assignments.firstWhere((a) => a.playerId == eliminatedId);

    final (label, color, icon) = switch (assignment.cardType) {
      CardType.main => ('MASUM', Colors.green, Icons.verified_user),
      CardType.black => ('SİYAH KART (Casus)', Colors.black87, Icons.visibility_off),
      CardType.white => ('BEYAZ KART (Casus)', Colors.blueGrey, Icons.help_outline),
    };

    return Scaffold(
      appBar: AppBar(title: Text('Tur ${round.roundNumber} • Sonuç Açıklanıyor')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: color),
              const SizedBox(height: 16),
              Text(
                '${eliminated.name} elendi!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(label, style: const TextStyle(color: Colors.white)),
                backgroundColor: color,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => provider.resolveReveal(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Devam Et'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}