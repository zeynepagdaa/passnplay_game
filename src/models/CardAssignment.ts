/**
 * CardAssignment.ts
 * -----------------------------------------------------------------------
 * Bir oyuncunun bir turdaki kart atamasını temsil eder.
 *
 * KRİTİK UI KURALI: MAIN ve BLACK atamalarının `word` alanı HER ZAMAN
 * dolu bir string'dir; sadece değer farklıdır. UI katmanı bu iki kart
 * türü için AYNI ekran bileşenini kullanmalı, aralarında hiçbir görsel
 * fark olmamalıdır — aksi halde Siyah Kart sahibi, ekranın farklı
 * göründüğünü fark ederek kendi rolünü tahmin edebilir. Sadece
 * `cardType === WHITE` durumunda `word === null` olur ve ayrı bir
 * "Beyaz Kart" ekranı gösterilir (bu ayrımın kendisi zaten oyunun bir
 * parçasıdır, açık vermez).
 */

export enum CardType {
  MAIN = "MAIN",
  BLACK = "BLACK",
  WHITE = "WHITE",
}

export interface CardAssignment {
  playerId: string;
  cardType: CardType;
  word: string | null; // WHITE için her zaman null
  hasViewed: boolean;
}

/**
 * Tüm oyuncular için kart atamalarını üretir.
 * - blackCardPlayerIds içindekiler -> BLACK (spyWord)
 * - whiteCardPlayerIds içindekiler -> WHITE (word: null)
 * - geri kalan herkes -> MAIN (mainWord)
 *
 * NOT: Aynı oyuncu id'si hem black hem white listesinde olamaz; bu
 * durum spyDistribution.pickSpyPlayers tarafından zaten garanti edilir
 * (tek bir shuffle edilmiş diziden ayrık dilimler alınır), ancak burada
 * da savunmacı bir kontrol yapılır.
 */
export function buildAssignments(
  playerIds: string[],
  mainWord: string,
  spyWord: string,
  blackCardPlayerIds: string[],
  whiteCardPlayerIds: string[]
): CardAssignment[] {
  const blackSet = new Set(blackCardPlayerIds);
  const whiteSet = new Set(whiteCardPlayerIds);

  const overlap = blackCardPlayerIds.filter((id) => whiteSet.has(id));
  if (overlap.length > 0) {
    throw new Error(
      `Bir oyuncu aynı anda hem Siyah hem Beyaz kart alamaz: ${overlap.join(", ")}`
    );
  }

  return playerIds.map((playerId) => {
    if (blackSet.has(playerId)) {
      return {
        playerId,
        cardType: CardType.BLACK,
        word: spyWord,
        hasViewed: false,
      };
    }
    if (whiteSet.has(playerId)) {
      return {
        playerId,
        cardType: CardType.WHITE,
        word: null,
        hasViewed: false,
      };
    }
    return {
      playerId,
      cardType: CardType.MAIN,
      word: mainWord,
      hasViewed: false,
    };
  });
}
