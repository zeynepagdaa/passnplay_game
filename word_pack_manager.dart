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
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Navigasyon ve Başlık Çubuğu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF2C3E50)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Kelime Paketleri',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB19CD9), // Pastel lila
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Yeni Paket',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showCreatePackDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Paket Listesi
              Expanded(
                child: ListView(
                  children: [
                    // Dahili Paket Kartı
                    _PackCard(pack: provider.builtinPack, provider: provider),

                    if (provider.customPacks.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Text(
                          'ÖZEL PAKETLER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Color(0xFF95A5A6),
                          ),
                        ),
                      ),
                      for (final pack in provider.customPacks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PackCard(pack: pack, provider: provider),
                        ),
                    ],
                  ],
                ),
              ),
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
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Paket Oluştur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Paket adı girin...',
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
                    child: const Text('İptal', style: TextStyle(color: Color(0xFF7F8C8D))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77DD77), // Pastel yeşil
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final error = provider.createCustomPack(controller.text);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: const Color(0xFFFFB7B2),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Oluştur'),
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
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFFAEC6CF) : const Color(0xFFE8E5DF),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Checkbox(
            activeColor: const Color(0xFF77DD77),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            value: isSelected,
            onChanged: (v) => provider.togglePackSelected(pack.id, v ?? false),
          ),
          title: Text(
            pack.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          subtitle: Text(
            '${pack.pairs.length} kelime çifti • ${pack.isEditable ? 'Özel' : 'Dahili (Salt Okunur)'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
          ),
          trailing: pack.isEditable
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: Color(0xFF77DD77)),
                      onPressed: () => _showAddPairDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFFFB7B2)),
                      onPressed: () => provider.deleteCustomPack(pack.id),
                    ),
                  ],
                )
              : const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFBDC3C7)),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F0EB),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  for (final pair in pack.pairs)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              pair.mainWord,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 14, color: Color(0xFF95A5A6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pair.spyWord,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8C5363),
                              ),
                            ),
                          ),
                          if (pack.isEditable)
                            GestureDetector(
                              onTap: () =>
                                  provider.removeWordPairFromPack(pack.id, pair.id),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Color(0xFFFFB7B2)),
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
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kelime Çifti Ekle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: mainCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Ana Kelime (Masumlar)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: spyCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Siyah Kelime (Çağrışımlı Casus)',
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
                    child: const Text('İptal', style: TextStyle(color: Color(0xFF7F8C8D))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77DD77),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final error = provider.addWordPairToPack(
                          pack.id, mainCtrl.text, spyCtrl.text);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: const Color(0xFFFFB7B2),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Ekle'),
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