import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';
import 'word_pack_manager_screen.dart';
import 'game_flow_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer(GameProvider provider) {
    final error = provider.addPlayer(_nameController.text);
    setState(() => _error = error);
    if (error == null) _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final maxSpies = provider.maxSpyCountForCurrentPlayers();
    final playerCount = provider.players.length;
    final hasEnoughPlayers = playerCount >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Başlık & Rozet Alanı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Oyun Kurulumu',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEC6CF).withValues(alpha: 0.35), // Pastel mavi rozet
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$playerCount Oyuncu',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3B4B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Oyuncu Ekleme Input Kartı
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8E5DF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                        decoration: InputDecoration(
                          hintText: 'Oyuncu adı yazın...',
                          hintStyle: const TextStyle(color: Color(0xFF95A5A6), fontSize: 15),
                          errorText: _error,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addPlayer(provider),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB19CD9), // Pastel lila
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _addPlayer(provider),
                      child: const Text(
                        'Ekle',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Oyuncu Listesi
              Expanded(
                child: playerCount == 0
                    ? Center(
                        child: Text(
                          'Henüz oyuncu eklenmedi.\nBaşlamak için isim yazıp ekleyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.5),
                        ),
                      )
                    : ListView.separated(
                        itemCount: playerCount,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = provider.players[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFBF7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE8E5DF)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFFD1DC), // Pastel pembe avatar
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF8C5363),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close_rounded, color: Color(0xFFFFB7B2)),
                                onPressed: () => provider.removePlayer(player.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Kural Bilgilendirme Kartı (%30 kuralı)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: hasEnoughPlayers
                      ? const Color(0xFFE8E5DF).withValues(alpha: 0.5)
                      : const Color(0xFFFFD1DC).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasEnoughPlayers ? Icons.info_outline : Icons.warning_amber_rounded,
                      size: 18,
                      color: hasEnoughPlayers ? const Color(0xFF555555) : const Color(0xFF8C5363),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasEnoughPlayers
                            ? '$playerCount oyuncu • Bu turda en fazla $maxSpies casus olabilir (%30 kuralı)'
                            : 'Oyun için en az 3 oyuncu gerekir.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasEnoughPlayers ? const Color(0xFF555555) : const Color(0xFF8C5363),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Kelime Paketleri Butonu
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDFBF7),
                  side: const BorderSide(color: Color(0xFFE8E5DF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.library_books_rounded, color: Color(0xFF4A3E72), size: 20),
                label: Text(
                  'Kelime Paketleri (${provider.selectedPackIds.length} seçili)',
                  style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WordPackManagerScreen()),
                ),
              ),
              const SizedBox(height: 10),

              // Oyunu Başlat Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasEnoughPlayers ? const Color(0xFF77DD77) : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: hasEnoughPlayers
                    ? () {
                        final error = provider.startGame();
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: const Color(0xFFFFB7B2),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const GameFlowScreen()),
                        );
                      }
                    : null,
                child: const Text(
                  'OYUNU BAŞLAT',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}