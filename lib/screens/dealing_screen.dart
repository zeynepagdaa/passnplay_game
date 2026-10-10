import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/game_provider.dart';
import '../widgets/rules_drawer.dart';
import 'game_card.dart';

class DealingScreen extends StatefulWidget {
  const DealingScreen({super.key});

  @override
  State<DealingScreen> createState() => _DealingScreenState();
}

class _DealingScreenState extends State<DealingScreen> {
  bool _isCardVisible = false;
  String? _lastPlayerId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final playerId = provider.engine!.getPlayerAwaitingCardView();

    if (_lastPlayerId != playerId) {
      _lastPlayerId = playerId;
      _isCardVisible = false;
    }

    final player = provider.players.firstWhere((p) => p.id == playerId);
    final assignment = round.assignments.firstWhere((a) => a.playerId == playerId);

    return Scaffold(
      drawer: const RulesDrawer(),
      appBar: AppBar(
        title: Text('TUR ${round.roundNumber} • KART DAĞITIMI'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              !_isCardVisible
                  ? _buildHandoffView(context, player.name)
                  : GameCard(
                      playerName: player.name,
                      word: assignment.word,
                      onConfirm: () {
                        provider.confirmCardViewed(playerId);
                        setState(() => _isCardVisible = false);
                      },
                    ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandoffView(BuildContext context, String playerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
            blurRadius: 16,
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
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.phone_android_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'SIRADAKİ OYUNCU',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 1.5,
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            playerName,
            style: GoogleFonts.bungee(
              fontSize: 26,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Lütfen telefonu $playerName adlı oyuncuya verin.\nDiğer oyuncular ekrana bakmamalıdır!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () => setState(() => _isCardVisible = true),
              child: Text(
                'BEN $playerName, HAZIRIM',
                style: GoogleFonts.bungee(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}