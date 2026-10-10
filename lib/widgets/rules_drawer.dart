import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RulesDrawer extends StatelessWidget {
  const RulesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'OYUN KURALLARI',
                style: GoogleFonts.bungee(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildRuleItem(context, '1. Dağıtım', 'Her oyuncuya gizli bir rol ve kelime verilir. Casuslar sahte kelime veya kelimesiz (beyaz kart) olabilir.'),
                  _buildRuleItem(context, '2. İpucu Aşaması', 'Herkes sırayla kelimesi hakkında tek kelimelik veya kısa bir ipucu verir. Casuslar kelimeyi bilmeden uyum sağlamaya çalışır.'),
                  _buildRuleItem(context, '3. Tartışma', 'İpuçları bittikten sonra herkesin tartışma hakkı vardır. Kimin casus olduğu analiz edilir.'),
                  _buildRuleItem(context, '4. Oylama', 'En şüpheli kişiye oy verilir. Casus bulunursa masumlar kazanır, masum asılırsa casus kazanır.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}