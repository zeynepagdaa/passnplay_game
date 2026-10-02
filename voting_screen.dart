import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// VOTING fazı: sadece activeOrder'daki (henüz elenmemiş) oyuncular
/// oy kullanabilir/oylanabilir. Karma Mod'da bir ara-eleme sonrası bu
/// liste küçülmüş olabilir — ekran otomatik olarak günceli gösterir.
class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final votedCount = round.votes.length;
    final total = round.activeOrder.length;

    return Scaffold(
      appBar: AppBar(title: Text('Tur ${round.roundNumber} • Oylama')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (round.eliminatedPlayerIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Bu turda daha önce ${round.eliminatedPlayerIds.length} casus yakalandı — '
                  'oylama devam ediyor.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            Text('Oy verildi: $votedCount / $total',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            const Text(
              'Tartışıp ortak kararla birini seçin,\nardından sırayla dokunarak oy kullanın.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: round.activeOrder.length,
                itemBuilder: (context, index) {
                  final candidateId = round.activeOrder[index];
                  final candidate = provider.players.firstWhere((p) => p.id == candidateId);
                  final votesForCandidate =
                      round.votes.values.where((v) => v == candidateId).length;
                  return Card(
                    child: ListTile(
                      title: Text(candidate.name),
                      trailing: votesForCandidate > 0
                          ? Chip(label: Text('$votesForCandidate oy'))
                          : null,
                      onTap: () => _castVote(context, provider, candidateId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _castVote(BuildContext context, GameProvider provider, String candidateId) {
    final round = provider.currentRound!;
    final remainingVoters =
        round.activeOrder.where((id) => !round.votes.containsKey(id)).toList();
    if (remainingVoters.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Kim oy kullanıyor?'),
        children: [
          for (final voterId in remainingVoters)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                provider.submitVote(voterId, candidateId);
              },
              child: Text(provider.players.firstWhere((p) => p.id == voterId).name),
            ),
        ],
      ),
    );
  }
}