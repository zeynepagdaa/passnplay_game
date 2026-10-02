import 'package:flutter/material.dart';
import 'game_card.dart';

class DealingScreen extends StatefulWidget {
  final String playerName;
  final String? currentWord;
  final VoidCallback onNextPlayer;

  const DealingScreen({
    Key? key,
    required this.playerName,
    required this.currentWord,
    required this.onNextPlayer,
  }) : super(key: key);

  @override
  State<DealingScreen> createState() => _DealingScreenState();
}

class _DealingScreenState extends State<DealingScreen> {
  bool _isCardVisible = false;

  void _handleConfirm() {
    setState(() {
      _isCardVisible = false;
    });
    // TS motorunu tetiklemek için callback fırlatıyoruz
    widget.onNextPlayer(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB), // Ekran geneli çok uçuk pastel gri
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: !_isCardVisible
                ? _buildHandoffView()
                : GameCard(
                    playerName: widget.playerName,
                    word: widget.currentWord,
                    onConfirm: _handleConfirm,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandoffView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFFFD1DC), // Pastel pembe ikon arka planı
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('📱', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sıradaki Oyuncu:',
          style: TextStyle(fontSize: 20, color: Color(0xFF7B7B7B)),
        ),
        const SizedBox(height: 5),
        Text(
          widget.playerName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Telefonu ${widget.playerName} isimli oyuncuya verin.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
        ),
        const SizedBox(height: 40),
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
            onPressed: () {
              setState(() {
                _isCardVisible = true;
              });
            },
            child: Text(
              'Ben ${widget.playerName}, Hazırım',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}