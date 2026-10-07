
// "Dinamik Tur Sıralaması" kuralı:
//  - Tur 1: sıralama tamamen rastgele (kura).
//  - Tur >=2: kart bakma/konuşma sırası en düşük puana sahip oyuncudan
//   başlar (ascending score). Eşit skorlarda sıralama, önceki turun
//   sırasına göre stabil tutulur (adil bir tie-break sağlamak için).

import '../models/player.dart';
import 'spy_distribution.dart';

/// [roundNumber] 1-indexed tur numarası.
/// [players] Tüm oyuncular (güncel skorlarıyla).
/// [previousTurnOrder] Bir önceki turun sıralaması (tie-break için).
List<String> getTurnOrder(
  int roundNumber,
  List<Player> players, {
  List<String> previousTurnOrder = const [],
}) {
  if (roundNumber <= 1) {
    return shuffleList(players.map((p) => p.id).toList());
  }

  final prevIndex = <String, int>{
    for (var i = 0; i < previousTurnOrder.length; i++) previousTurnOrder[i]: i,
  };

  final sorted = List<Player>.from(players);
  sorted.sort((a, b) {
    if (a.score != b.score) return a.score - b.score; // düşük puan önce
    final ai = prevIndex[a.id] ?? (1 << 30);
    final bi = prevIndex[b.id] ?? (1 << 30);
    return ai - bi;
  });
  return sorted.map((p) => p.id).toList();
}