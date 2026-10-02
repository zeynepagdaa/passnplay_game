
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word_pack.dart';
import '../state/game_provider.dart';

class WordPackManagerScreen extends StatelessWidget {
  const WordPackManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Paketleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni paket oluştur',
            onPressed: () => _showCreatePackDialog(context, provider),
          ),
        ],
      ),
      body: ListView(
        children: [
          _PackTile(pack: provider.builtinPack, provider: provider),
          const Divider(),
          for (final pack in provider.customPacks) _PackTile(pack: pack, provider: provider),
        ],
      ),
    );
  }

  void _showCreatePackDialog(BuildContext context, GameProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Paket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Paket adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              final error = provider.createCustomPack(controller.text);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.pop(context);
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final WordPack pack;
  final GameProvider provider;
  const _PackTile({required this.pack, required this.provider});

  @override
  Widget build(BuildContext context) {
    final selected = provider.selectedPackIds.contains(pack.id);
    return ExpansionTile(
      leading: Checkbox(
        value: selected,
        onChanged: (v) => provider.togglePackSelected(pack.id, v ?? false),
      ),
      title: Text(pack.name),
      subtitle: Text(
        '${pack.pairs.length} kelime çifti'
        '${pack.isEditable ? '' : ' • dahili (salt okunur)'}',
      ),
      trailing: pack.isEditable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddPairDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.deleteCustomPack(pack.id),
                ),
              ],
            )
          : null,
      children: [
        for (final pair in pack.pairs)
          ListTile(
            dense: true,
            title: Text('${pair.mainWord}  →  ${pair.spyWord}'),
            trailing: pack.isEditable
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => provider.removeWordPairFromPack(pack.id, pair.id),
                  )
                : null,
          ),
      ],
    );
  }

  void _showAddPairDialog(BuildContext context) {
    final mainCtrl = TextEditingController();
    final spyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelime Çifti Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: mainCtrl, decoration: const InputDecoration(labelText: 'Ana Kelime')),
            TextField(controller: spyCtrl, decoration: const InputDecoration(labelText: 'Siyah Kelime (çağrışımlı)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              final error = provider.addWordPairToPack(pack.id, mainCtrl.text, spyCtrl.text);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}