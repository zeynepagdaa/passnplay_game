import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/game_provider.dart';
import '../widgets/rules_drawer.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final votedCount = round.votes.length;
    final total = round.activeOrder.length;
    final isVotingComplete = votedCount == total;

    return Scaffold(
      drawer: const RulesDrawer(),
      appBar: AppBar(
        title: const Text('OYLAMA'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sayaç Rozeti
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tur ${round.roundNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Oy: $votedCount / $total',
                      style: GoogleFonts.bungee(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (round.eliminatedPlayerIds.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu turda ${round.eliminatedPlayerIds.length} casus yakalandı. Kalan casus için oylama sürüyor.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Text(
                'ŞÜPHELİYİ SEÇİN',
                style: GoogleFonts.bungee(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Casus olduğunu düşündüğünüz oyuncuya dokunarak oy verin.',
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: round.activeOrder.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final candidateId = round.activeOrder[index];
                    final candidate =
                        provider.players.firstWhere((p) => p.id == candidateId);
                    final votesForCandidate =
                        round.votes.values.where((v) => v == candidateId).length;

                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: votesForCandidate > 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.surface,
                          width: votesForCandidate > 0 ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            candidate.name.isNotEmpty
                                ? candidate.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        trailing: votesForCandidate > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$votesForCandidate OY',
                                  style: GoogleFonts.bungee(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: () => _castVote(context, provider, candidateId),
                      ),
                    );
                  },
                ),
              ),

              if (isVotingComplete)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => provider.resolveVotingResult(),
                    child: Text(
                      'OYLAMAYI BİTİR • KARTI AÇ',
                      style: GoogleFonts.bungee(fontSize: 15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _castVote(BuildContext context, GameProvider provider, String candidateId) {
    final round = provider.currentRound!;
    final remainingVoters =
        round.activeOrder.where((id) => !round.votes.containsKey(id)).toList();
    if (remainingVoters.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'KİM OY KULLANIYOR?',
              style: GoogleFonts.bungee(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kendi isminize dokunarak oyunuzu onaylayın.',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remainingVoters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final voterId = remainingVoters[index];
                final voter = provider.players.firstWhere((p) => p.id == voterId);
                return ListTile(
                  tileColor: const Color(0xFF1A1A24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(Icons.how_to_vote, color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                    voter.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    provider.submitVote(voterId, candidateId);
                  },
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}