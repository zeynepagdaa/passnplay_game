/**
 * spyDistribution.ts
 * -----------------------------------------------------------------------
 * "Casus Sayısı Sınırı & Karma Mod" kuralının tek doğru kaynağı (single
 * source of truth). Tüm oyun bu dosyadaki fonksiyonlara güvenmeli;
 * casus sayısı hesaplaması başka hiçbir yerde tekrar yazılmamalı.
 *
 * KURAL (verilen formül, birebir):
 *   maxSpies = Math.floor(playerCount * 0.30)
 *
 * MÜHENDİSLİK NOTU (önemli, bilinçli tasarım kararı):
 * Bu formül n=6 için Math.floor(6 * 0.30) = 1 sonucunu verir. Yani "6
 * oyuncudan itibaren birden fazla casus / karma mod" ifadesi ancak
 * n>=7'de matematiksel olarak mümkün hale gelir (floor(7*0.30)=2).
 * Bu bir hata değil — formül birebir uygulanıyor. allowMixedMode bayrağı
 * n>=6 olduğunda AÇILABİLİR ama gerçekte birden fazla casus ancak cap
 * (maxSpies) buna izin verdiğinde devreye girer. Bu davranış kasıtlı
 * olarak burada dokümante edildi ki ileride "bug" sanılıp formül
 * değiştirilmesin.
 *
 * Ayrıca oyunun her zaman oynanabilir olması için (n=3,4,5 gibi düşük
 * sayılarda formül 0 üretebilir) minimum 1 casus garantisi eklendi.
 */

import { CardType } from "../models/CardAssignment";

export const MIN_PLAYERS = 3;
export const DEFAULT_MAX_SPY_RATIO = 0.3;
export const MULTI_SPY_THRESHOLD = 6; // Karma mod / çoklu casus için minimum oyuncu sayısı eşiği

export interface SpyDistribution {
  blackCount: number;
  whiteCount: number;
  total: number;
}

export type SpyModePreference =
  | "BLACK_ONLY"   // Sadece Siyah Kart casusu kullan
  | "WHITE_ONLY"   // Sadece Beyaz Kart casusu kullan
  | "MIXED"        // Hem Siyah hem Beyaz aynı turda (sadece n>=6 ve cap izin veriyorsa)
  | "RANDOM";       // Her tur rastgele karar ver (cap'e uyarak)

/**
 * Verilen oyuncu sayısı için izin verilen MAKSİMUM toplam casus sayısını
 * döndürür. Formül: Math.floor(playerCount * maxSpyRatio), en az 1.
 */
export function getMaxSpyCount(
  playerCount: number,
  maxSpyRatio: number = DEFAULT_MAX_SPY_RATIO
): number {
  if (playerCount < MIN_PLAYERS) {
    throw new Error(
      `Oyun en az ${MIN_PLAYERS} oyuncu gerektirir (verilen: ${playerCount}).`
    );
  }
  const rawCap = Math.floor(playerCount * maxSpyRatio);
  return Math.max(1, rawCap); // oyun her zaman en az 1 casus içermeli
}

/**
 * Bir turluk casus dağılımını (kaç Siyah, kaç Beyaz) hesaplar.
 * Cap'i (getMaxSpyCount) ASLA aşmaz.
 */
export function calculateSpyDistribution(
  playerCount: number,
  preference: SpyModePreference = "RANDOM",
  maxSpyRatio: number = DEFAULT_MAX_SPY_RATIO
): SpyDistribution {
  const maxSpies = getMaxSpyCount(playerCount, maxSpyRatio);
  const canGoMulti = playerCount >= MULTI_SPY_THRESHOLD && maxSpies >= 2;
  const canMix = canGoMulti; // karma mod, çoklu casusun bir alt kümesi

  // --- Tek casus zorunlu senaryo (playerCount < 6 ya da cap=1) ---
  if (!canGoMulti) {
    const type = resolveSingleSpyType(preference);
    return type === CardType.BLACK
      ? { blackCount: 1, whiteCount: 0, total: 1 }
      : { blackCount: 0, whiteCount: 1, total: 1 };
  }

  // --- Çoklu casus mümkün senaryo (playerCount >= 6 ve maxSpies >= 2) ---
  switch (preference) {
    case "BLACK_ONLY":
      return { blackCount: maxSpies, whiteCount: 0, total: maxSpies };

    case "WHITE_ONLY":
      return { blackCount: 0, whiteCount: maxSpies, total: maxSpies };

    case "MIXED": {
      if (!canMix) {
        // Karma mod istenmiş ama matematiksel olarak mümkün değil (n=6, cap=1 gibi);
        // güvenli şekilde tek tür casusa düş.
        return { blackCount: maxSpies, whiteCount: 0, total: maxSpies };
      }
      return splitMixedSpies(maxSpies);
    }

    case "RANDOM":
    default: {
      // %50 ihtimalle tek tür (siyah veya beyaz ağırlıklı), %50 ihtimalle karma.
      const goMixed = canMix && Math.random() < 0.5;
      if (goMixed) return splitMixedSpies(maxSpies);
      const type = resolveSingleSpyType("RANDOM");
      return type === CardType.BLACK
        ? { blackCount: maxSpies, whiteCount: 0, total: maxSpies }
        : { blackCount: 0, whiteCount: maxSpies, total: maxSpies };
    }
  }
}

/** maxSpies'ı Siyah/Beyaz arasında en az 1'er olacak şekilde rastgele böler. */
function splitMixedSpies(maxSpies: number): SpyDistribution {
  // maxSpies >= 2 garantisi canMix kontrolünde sağlandı.
  const blackCount = 1 + Math.floor(Math.random() * (maxSpies - 1));
  const whiteCount = maxSpies - blackCount;
  return { blackCount, whiteCount, total: maxSpies };
}

function resolveSingleSpyType(preference: SpyModePreference): CardType.BLACK | CardType.WHITE {
  if (preference === "BLACK_ONLY") return CardType.BLACK;
  if (preference === "WHITE_ONLY") return CardType.WHITE;
  return Math.random() < 0.5 ? CardType.BLACK : CardType.WHITE;
}

/**
 * Oyuncu id listesinden, verilen dağılıma göre rastgele Siyah/Beyaz kart
 * sahiplerini seçer. Geri kalan herkes MAIN (masum) kart alır.
 */
export function pickSpyPlayers(
  playerIds: string[],
  distribution: SpyDistribution
): { blackCardPlayerIds: string[]; whiteCardPlayerIds: string[] } {
  const shuffled = shuffleArray(playerIds);
  const blackCardPlayerIds = shuffled.slice(0, distribution.blackCount);
  const whiteCardPlayerIds = shuffled.slice(
    distribution.blackCount,
    distribution.blackCount + distribution.whiteCount
  );
  return { blackCardPlayerIds, whiteCardPlayerIds };
}

/** Fisher-Yates shuffle — mutasyonsuz (yeni dizi döner). */
export function shuffleArray<T>(input: T[]): T[] {
  const arr = [...input];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
