/**
 * wordSelection.ts
 * -----------------------------------------------------------------------
 * Seçilen paketlerden (default + custom) TEK BİR birleşik havuz oluşturup
 * her tur için tekrarsız (aynı oyun session'ı içinde) bir WordPair seçer.
 */

import { WordPair, WordPack } from "../models/WordPack";
import { shuffleArray } from "./spyDistribution";

/**
 * Seçilen pack id'lerine ait tüm çiftleri TEK bir düz diziye
 * (havuza) indirger. Kategori/pack ayrımı burada bilerek KAYBEDİLİR —
 * seçim aşamasından sonra hangi kelimenin hangi paketten geldiğinin
 * hiçbir önemi kalmamalı (tek blok kuralı).
 */
export function buildUnifiedWordPool(
  allPacks: WordPack[],
  selectedPackIds: string[]
): WordPair[] {
  const selectedSet = new Set(selectedPackIds);
  return allPacks
    .filter((pack) => selectedSet.has(pack.id))
    .flatMap((pack) => pack.pairs);
}

/**
 * Havuzdan, `usedPairIds` içinde olmayan rastgele bir WordPair seçer.
 * Havuz tükenirse (tüm çiftler kullanıldıysa) `usedPairIds` sıfırlanmış
 * gibi davranıp havuzun tamamından tekrar seçim yapılır (oyun asla
 * kelime kalmadığı için tıkanmamalı).
 */
export function pickNextWordPair(
  pool: WordPair[],
  usedPairIds: Set<string>
): WordPair {
  if (pool.length === 0) {
    throw new Error(
      "Kelime havuzu boş. Lütfen en az bir paket seçin veya varsayılan " +
        "kütüphaneyi dahil edin."
    );
  }

  let available = pool.filter((pair) => !usedPairIds.has(pair.id));
  if (available.length === 0) {
    // Havuz tükendi -> tekrar kullanıma aç (döngüsel havuz).
    available = pool;
  }

  const [picked] = shuffleArray(available);
  return picked;
}
