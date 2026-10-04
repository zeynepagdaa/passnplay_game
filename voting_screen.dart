import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// VOTING fazı: sadece activeOrder'daki (elenmemiş) oyuncular listelenir ve oy kullanır.
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
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Bilgi Barı (Tur & Sayaç Rozetleri)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5DF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tur ${round.roundNumber} • Oylama',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB7B2).withOpacity(0.35), // Pastel somon rozet
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Oy: $votedCount / $total',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C5363),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Çoklu Casus / Ara Eleme Bildirim Kartı
              if (round.eliminatedPlayerIds.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD1DC).withOpacity(0.5), // Pastel pembe
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD1DC)),
                  ),
                  child: Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu turda ${round.eliminatedPlayerIds.length} casus yakalandı. Kalan casus için oylama sürüyor.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C5363),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Başlık ve Açıklama Alanı
              const Text(
                'Şüpheliyi Seçin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kimin casus olduğunu düşünüyorsanız üzerine dokunarak oy verin.',
                style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 16),

              // Aday Oyuncu Listesi
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
                        color: const Color(0xFFFDFBF7), // Pastel kart rengi
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: votesForCandidate > 0
                              ? const Color(0xFFAEC6CF) // Oy almışsa pastel mavi çerçeve
                              : const Color(0xFFE8E5DF),
                          width: votesForCandidate > 0 ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDCD0FF), // Pastel lila avatar
                          child: Text(
                            candidate.name.isNotEmpty
                                ? candidate.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF4A3E72),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        trailing: votesForCandidate > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFAEC6CF), // Pastel mavi oy rozeti
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$votesForCandidate oy',
                                  style: const TextStyle(
                                    color: Color(0xFF1B3B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Icon(Icons.chevron_right,
                                color: Color(0xFFBDC3C7)),
                        onTap: () => _castVote(context, provider, candidateId),
                      ),
                    );
                  },
                ),
              ),

              // Tüm Oylar Verildiğinde Çıkan İlerleme Butonu
              if (isVotingComplete)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77DD77), // Pastel yeşil
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => provider.engine?.resolveVotingResult(),
                    child: const Text(
                      'Oylamayı Tamamla • Kartı Aç',
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
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: const Color(0xFFE8E5DF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Kim oy kullanıyor?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kendi isminize dokunarak oyunuzu kaydedin.',
              style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remainingVoters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final voterId = remainingVoters[index];
                final voter =
                    provider.players.firstWhere((p) => p.id == voterId);
                return ListTile(
                  tileColor: const Color(0xFFF2F0EB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.how_to_vote,
                      color: Color(0xFFB19CD9)), // Pastel lila ikon
                  title: Text(
                    voter.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
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