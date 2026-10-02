/// player.dart
/// -----------------------------------------------------------------------
/// Oyuncu modeli. GameEngine ve turnOrder bu sınıfa güvenir.
/// (TypeScript prototipinden [Player.ts] birebir taşınmıştır.)

class Player {
  final String id;
  final String name;
  int score;

  Player({required this.id, required this.name, this.score = 0});
}

int _playerCounter = 0;

/// Basit, çakışmasız bir id üretir (zaman damgası + artan sayaç + random).
String _generateId(String prefix) {
  _playerCounter += 1;
  final rand = (DateTime.now().microsecondsSinceEpoch % 1000000)
      .toRadixString(36);
  final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  return '${prefix}_${ts}_${_playerCounter}_$rand';
}

/// Yeni bir oyuncu oluşturur. Skor her zaman 0'dan başlar.
/// İsim baştaki/sondaki boşluklardan arındırılır; boş isim kabul edilmez.
Player createPlayer(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Oyuncu adı boş olamaz.');
  }
  return Player(id: _generateId('player'), name: trimmed);
}