import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';
import '../engine/spy_distribution.dart';
import 'word_pack_manager_screen.dart';
import 'game_flow_screen.dart';
import '../widgets/rules_drawer.dart';

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
      drawer: const RulesDrawer(),
      appBar: AppBar(
        title: const Text('Casus Oyunu'),
      ),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$playerCount Oyuncu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Oyuncu adı yazın...',
                          errorText: _error,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addPlayer(provider),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _addPlayer(provider),
                      child: const Text(
                        'Ekle',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.error),
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
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasEnoughPlayers ? Icons.info_outline : Icons.warning_amber_rounded,
                      size: 18,
                      color: hasEnoughPlayers
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error,
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
                          color: hasEnoughPlayers ? Colors.white70 : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Kelime Paketleri Butonu
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(Icons.library_books_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                label: Text(
                  'Kelime Paketleri (${provider.selectedPackIds.length} seçili)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WordPackManagerScreen()),
                ),
              ),
              const SizedBox(height: 12),

              // Casus Modu Seçimi (SegmentedButton)
              SegmentedButton<SpyModePreference>(
                segments: const [
                  ButtonSegment(
                    value: SpyModePreference.blackOnly,
                    label: Text('Siyah Kart', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: SpyModePreference.whiteOnly,
                    label: Text('Beyaz Kart', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: SpyModePreference.random,
                    label: Text('Karışık', style: TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {provider.selectedSpyMode},
                onSelectionChanged: (Set<SpyModePreference> newSelection) {
                  provider.setSpyMode(newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).colorScheme.error;
                      }
                      return Theme.of(context).colorScheme.surface;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Oyunu Başlat Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasEnoughPlayers
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade700,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: hasEnoughPlayers
                    ? () {
                        final error = provider.startGame();
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Theme.of(context).colorScheme.error,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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