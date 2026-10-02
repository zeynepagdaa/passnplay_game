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

    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Kurulumu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Oyuncu adı',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(provider),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addPlayer(provider),
                  child: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: provider.players.length,
                itemBuilder: (context, index) {
                  final player = provider.players[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(player.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => provider.removePlayer(player.id),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              provider.players.length >= 3
                  ? '${provider.players.length} oyuncu • bu turda en fazla $maxSpies casus olabilir (%30 kuralı)'
                  : 'Oyun için en az 3 oyuncu gerekir.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.library_books_outlined),
              label: Text('Kelime Paketleri (${provider.selectedPackIds.length} seçili)'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WordPackManagerScreen()),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                final error = provider.startGame();
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GameFlowScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('OYUNU BAŞLAT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}