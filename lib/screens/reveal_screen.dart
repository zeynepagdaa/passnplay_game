import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/card_assignment.dart';
import '../state/game_provider.dart';
import '../widgets/rules_drawer.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final eliminatedId = round.eliminatedPlayerId!;
    final eliminated = provider.players.firstWhere((p) => p.id == eliminatedId);
    final assignment = round.assignments.firstWhere((a) => a.playerId == eliminatedId);

    final (roleTitle, roleDesc, accentColor, emoji) = switch (assignment.cardType) {
      CardType.main => (
          'MASUM',
          'Yanlış kişi oylandı! Masum bir oyuncu elendi.',
          Theme.of(context).colorScheme.primary, // Elektrik mavisi
          '🛡️',
        ),
      CardType.black => (
          'SİYAH KART (CASUS)',
          'Tebrikler! Sahte kelimeye sahip casus açığa çıktı.',
          Theme.of(context).colorScheme.error, // Fuşya / Kırmızı
          '🕵️',
        ),
      CardType.white => (
          'BEYAZ KART (CASUS)',
          'Kelimesiz casus yakalandı! Şimdi ana kelimeyi tahmin etme hakkı var.',
          Theme.of(context).colorScheme.secondary, // Neon Sarı
          '⚪',
        ),
    };

    return Scaffold(
      drawer: const RulesDrawer(),
      appBar: AppBar(
        title: const Text('KİMLİK AÇIKLANIYOR'),
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
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${eliminated.name} elendi!',
                      style: GoogleFonts.bungee(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleTitle,
                        style: GoogleFonts.bungee(
                          color: (accentColor == Theme.of(context).colorScheme.secondary ||
                                  accentColor == Theme.of(context).colorScheme.primary)
                              ? Colors.black
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      roleDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => provider.resolveReveal(),
                  child: Text(
                    'DEVAM ET',
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