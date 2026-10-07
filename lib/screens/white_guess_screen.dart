import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// Özel Beyaz Kart kuralı: yakalanan Beyaz Kart sahibi, ana kelimeyi
/// tahmin ederse turu TEK BAŞINA kazanır.
class WhiteGuessScreen extends StatefulWidget {
  const WhiteGuessScreen({super.key});

  @override
  State<WhiteGuessScreen> createState() => _WhiteGuessScreenState();
}

class _WhiteGuessScreenState extends State<WhiteGuessScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitGuess(GameProvider provider, String guesserId) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    provider.submitWhiteCardGuess(guesserId, text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final round = provider.currentRound!;
    final guesser =
        provider.players.firstWhere((p) => p.id == round.eliminatedPlayerId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Pastel krem arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Üst Bilgi Rozeti
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Beyaz Kart • Son Şans',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Ana Tahmin Kartı
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFB19CD9).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon Alanı
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE7F6), // Pastel leylak
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Başlık
                    Text(
                      '${guesser.name}, yakalandın!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Kural Açıklaması
                    const Text(
                      'Ama oyun henüz bitmedi.\nAna kelimeyi doğru tahmin edersen turu TEK BAŞINA kazanırsın!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tahmin Giriş Alanı
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F0EB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E5DF)),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 1.1,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tahminini buraya yaz...',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _submitGuess(provider, guesser.id),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Onay Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB19CD9), // Pastel lila
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _submitGuess(provider, guesser.id),
                  child: const Text(
                    'Tahminimi Onayla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}