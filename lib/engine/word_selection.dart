/// word_selection.dart
/// -----------------------------------------------------------------------
/// Seçilen paketlerden (default + custom) TEK BİR birleşik havuz oluşturup
/// her tur için tekrarsız (aynı oyun session'ı içinde) bir WordPair seçer.

import '../models/word_pack.dart';
import 'spy_distribution.dart';

/// Seçilen pack id'lerine ait tüm çiftleri TEK bir düz listeye (havuza)
/// indirger. Kategori/pack ayrımı burada bilerek KAYBEDİLİR — seçim
/// aşamasından sonra hangi kelimenin hangi paketten geldiğinin hiçbir
/// önemi kalmamalı (tek blok kuralı).
List<WordPair> buildUnifiedWordPool(
  List<WordPack> allPacks,
  List<String> selectedPackIds,
) {
  final selectedSet = selectedPackIds.toSet();
  final pool = <WordPair>[];
  for (final pack in allPacks) {
    if (selectedSet.contains(pack.id)) {
      pool.addAll(pack.pairs);
    }
  }
  return pool;
}

/// Havuzdan, [usedPairIds] içinde olmayan rastgele bir WordPair seçer.
/// Havuz tükenirse tüm havuzdan tekrar seçim yapılır (oyun asla kelime
/// kalmadığı için tıkanmamalı).
WordPair pickNextWordPair(List<WordPair> pool, Set<String> usedPairIds) {
  if (pool.isEmpty) {
    throw StateError(
        'Kelime havuzu boş. Lütfen en az bir paket seçin veya varsayılan '
        'kütüphaneyi dahil edin.');
  }

  var available = pool.where((p) => !usedPairIds.contains(p.id)).toList();
  if (available.isEmpty) {
    available = pool; // döngüsel havuz
  }

  final shuffled = shuffleList(available);
  return shuffled.first;
}