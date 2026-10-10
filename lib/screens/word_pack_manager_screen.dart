import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/word_pack.dart';
import '../state/game_provider.dart';

class WordPackManagerScreen extends StatelessWidget {
  const WordPackManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      appBar: AppBar(
        title: const Text('KELİME PAKETLERİ'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF00E5FF)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF00E5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('YENİ', style: GoogleFonts.bungee(fontSize: 12)),
              onPressed: () => _showCreatePackDialog(context, provider),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              _PackCard(pack: provider.builtinPack, provider: provider),
              if (provider.customPacks.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(
                    'ÖZEL PAKETLER',
                    style: GoogleFonts.bungee(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      color: const Color(0xFFFFD600),
                    ),
                  ),
                ),
                for (final pack in provider.customPacks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PackCard(pack: pack, provider: provider),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePackDialog(BuildContext context, GameProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF232332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YENİ PAKET OLUŞTUR',
                style: GoogleFonts.bungee(
                  fontSize: 16,
                  color: const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Paket adı girin...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İPTAL', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final error = provider.createCustomPack(controller.text);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: const Color(0xFFFF3366),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: Text('OLUŞTUR', style: GoogleFonts.bungee(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final WordPack pack;
  final GameProvider provider;

  const _PackCard({required this.pack, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.selectedPackIds.contains(pack.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232332),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Checkbox(
            activeColor: const Color(0xFF00E5FF),
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            value: isSelected,
            onChanged: (v) => provider.togglePackSelected(pack.id, v ?? false),
          ),
          title: Text(
            pack.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            '${pack.pairs.length} kelime çifti • ${pack.isEditable ? 'Özel' : 'Dahili (Salt Okunur)'}',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          trailing: pack.isEditable
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00E5FF)),
                      onPressed: () => _showAddPairDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3366)),
                      onPressed: () => provider.deleteCustomPack(pack.id),
                    ),
                  ],
                )
              : const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white30),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A24),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  for (final pair in pack.pairs)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232332),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              pair.mainWord,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white38),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pair.spyWord,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF3366),
                              ),
                            ),
                          ),
                          if (pack.isEditable)
                            GestureDetector(
                              onTap: () => provider.removeWordPairFromPack(pack.id, pair.id),
                              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFFF3366)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPairDialog(BuildContext context) {
    final mainCtrl = TextEditingController();
    final spyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF232332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KELİME ÇİFTİ EKLE',
                style: GoogleFonts.bungee(
                  fontSize: 16,
                  color: const Color(0xFFFFD600),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: mainCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ana Kelime (Masumlar)',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: spyCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Siyah Kelime (Çağrışımlı Casus)',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İPTAL', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final error = provider.addWordPairToPack(
                          pack.id, mainCtrl.text, spyCtrl.text);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: const Color(0xFFFF3366),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: Text('EKLE', style: GoogleFonts.bungee(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}