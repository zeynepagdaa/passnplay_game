/// card_assignment.dart
/// -----------------------------------------------------------------------
/// Bir oyuncunun bir turdaki kart atamasını temsil eder.
///
/// KRİTİK UI KURALI: MAIN ve BLACK atamalarının `word` alanı HER ZAMAN
/// dolu bir string'dir; sadece değer farklıdır. UI katmanı bu iki kart
/// türü için AYNI ekran widget'ını kullanmalı, aralarında hiçbir görsel
/// fark olmamalıdır — aksi halde Siyah Kart sahibi kendi rolünü tahmin
/// edebilir. Sadece `cardType == CardType.white` durumunda `word == null`
/// olur ve ayrı bir "Beyaz Kart" ekranı gösterilir.

enum CardType { main, black, white }

class CardAssignment {
  final String playerId;
  final CardType cardType;
  final String? word; // WHITE için her zaman null
  bool hasViewed;

  CardAssignment({
    required this.playerId,
    required this.cardType,
    required this.word,
    this.hasViewed = false,
  });
}

/// Tüm oyuncular için kart atamalarını üretir.
/// - blackCardPlayerIds içindekiler -> BLACK (spyWord)
/// - whiteCardPlayerIds içindekiler -> WHITE (word: null)
/// - geri kalan herkes -> MAIN (mainWord)
List<CardAssignment> buildAssignments(
  List<String> playerIds,
  String mainWord,
  String spyWord,
  List<String> blackCardPlayerIds,
  List<String> whiteCardPlayerIds,
) {
  final blackSet = blackCardPlayerIds.toSet();
  final whiteSet = whiteCardPlayerIds.toSet();

  final overlap = blackCardPlayerIds.where((id) => whiteSet.contains(id)).toList();
  if (overlap.isNotEmpty) {
    throw StateError(
        'Bir oyuncu aynı anda hem Siyah hem Beyaz kart alamaz: ${overlap.join(", ")}');
  }

  return playerIds.map((playerId) {
    if (blackSet.contains(playerId)) {
      return CardAssignment(playerId: playerId, cardType: CardType.black, word: spyWord);
    }
    if (whiteSet.contains(playerId)) {
      return CardAssignment(playerId: playerId, cardType: CardType.white, word: null);
    }
    return CardAssignment(playerId: playerId, cardType: CardType.main, word: mainWord);
  }).toList();
}