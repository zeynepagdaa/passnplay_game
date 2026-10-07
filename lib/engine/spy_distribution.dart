
// "Casus Sayısı Sınırı & Karma Mod" kuralının tek doğru kaynağı.
//
// KURAL (verilen formül, birebir):
//   maxSpies = (playerCount * 0.30).floor(), en az 1.
//
// n=6 için (6*0.30).floor() = 1 sonucunu verir; yani
// "6 oyuncudan itibaren birden fazla casus / karma mod" ifadesi ancak
// n>=7'de matematiksel olarak mümkün hale gelir ((7*0.30).floor()=2).
// Bu kasıtlı bir tasarım kararıdır, TypeScript prototipinde de
// dokümante edilmiştir — formül değiştirilmemelidir.

import 'dart:math';
import '../models/card_assignment.dart';

const int minPlayers = 3;
const double defaultMaxSpyRatio = 0.3;
const int multiSpyThreshold = 6;

enum SpyModePreference { blackOnly, whiteOnly, mixed, random }

class SpyDistribution {
  final int blackCount;
  final int whiteCount;
  int get total => blackCount + whiteCount;
  const SpyDistribution({required this.blackCount, required this.whiteCount});
}

final Random _rng = Random();

/// Verilen oyuncu sayısı için izin verilen MAKSİMUM toplam casus sayısı.
int getMaxSpyCount(int playerCount, {double maxSpyRatio = defaultMaxSpyRatio}) {
  if (playerCount < minPlayers) {
    throw ArgumentError(
        'Oyun en az $minPlayers oyuncu gerektirir (verilen: $playerCount).');
  }
  final rawCap = (playerCount * maxSpyRatio).floor();
  return max(1, rawCap);
}

/// Bir turluk casus dağılımını (kaç Siyah, kaç Beyaz) hesaplar.
/// Cap'i (getMaxSpyCount) ASLA aşmaz.
SpyDistribution calculateSpyDistribution(
  int playerCount, {
  SpyModePreference preference = SpyModePreference.random,
  double maxSpyRatio = defaultMaxSpyRatio,
}) {
  final maxSpies = getMaxSpyCount(playerCount, maxSpyRatio: maxSpyRatio);
  final canGoMulti = playerCount >= multiSpyThreshold && maxSpies >= 2;

  // --- Tek casus zorunlu senaryo (playerCount < 6 ya da cap=1) ---
  if (!canGoMulti) {
    final type = _resolveSingleSpyType(preference);
    return type == CardType.black
        ? const SpyDistribution(blackCount: 1, whiteCount: 0)
        : const SpyDistribution(blackCount: 0, whiteCount: 1);
  }

  // --- Çoklu casus mümkün senaryo (playerCount >= 6 ve maxSpies >= 2) ---
  switch (preference) {
    case SpyModePreference.blackOnly:
      return SpyDistribution(blackCount: maxSpies, whiteCount: 0);
    case SpyModePreference.whiteOnly:
      return SpyDistribution(blackCount: 0, whiteCount: maxSpies);
    case SpyModePreference.mixed:
      return _splitMixedSpies(maxSpies);
    case SpyModePreference.random:
      final goMixed = _rng.nextDouble() < 0.5;
      if (goMixed) return _splitMixedSpies(maxSpies);
      final type = _resolveSingleSpyType(SpyModePreference.random);
      return type == CardType.black
          ? SpyDistribution(blackCount: maxSpies, whiteCount: 0)
          : SpyDistribution(blackCount: 0, whiteCount: maxSpies);
  }
}

/// maxSpies'ı Siyah/Beyaz arasında en az 1'er olacak şekilde rastgele böler.
SpyDistribution _splitMixedSpies(int maxSpies) {
  // maxSpies >= 2 garantisi canGoMulti kontrolünde sağlandı.
  final blackCount = 1 + _rng.nextInt(maxSpies - 1);
  final whiteCount = maxSpies - blackCount;
  return SpyDistribution(blackCount: blackCount, whiteCount: whiteCount);
}

CardType _resolveSingleSpyType(SpyModePreference preference) {
  if (preference == SpyModePreference.blackOnly) return CardType.black;
  if (preference == SpyModePreference.whiteOnly) return CardType.white;
  return _rng.nextDouble() < 0.5 ? CardType.black : CardType.white;
}

class SpyPlayerSelection {
  final List<String> blackCardPlayerIds;
  final List<String> whiteCardPlayerIds;
  const SpyPlayerSelection({
    required this.blackCardPlayerIds,
    required this.whiteCardPlayerIds,
  });
}

/// Oyuncu id listesinden, verilen dağılıma göre rastgele Siyah/Beyaz kart
/// sahiplerini seçer. Geri kalan herkes MAIN (masum) kart alır.
SpyPlayerSelection pickSpyPlayers(List<String> playerIds, SpyDistribution distribution) {
  final shuffled = shuffleList(playerIds);
  final blackCardPlayerIds = shuffled.sublist(0, distribution.blackCount);
  final whiteCardPlayerIds = shuffled.sublist(
    distribution.blackCount,
    distribution.blackCount + distribution.whiteCount,
  );
  return SpyPlayerSelection(
    blackCardPlayerIds: blackCardPlayerIds,
    whiteCardPlayerIds: whiteCardPlayerIds,
  );
}

/// Fisher-Yates shuffle — mutasyonsuz (yeni liste döner).
List<T> shuffleList<T>(List<T> input) {
  final arr = List<T>.from(input);
  for (var i = arr.length - 1; i > 0; i--) {
    final j = _rng.nextInt(i + 1);
    final tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }
  return arr;
}