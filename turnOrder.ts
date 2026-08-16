/**
 * turnOrder.ts
 * -----------------------------------------------------------------------
 * "Dinamik Tur Sıralaması" kuralı:
 *  - Tur 1: sıralama tamamen rastgele (kura).
 *  - Tur >=2: kart bakma/konuşma sırası en düşük puana sahip oyuncudan
 *    başlar (ascending score). Eşit skorlarda sıralama, önceki turun
 *    sırasına göre stabil tutulur (adil bir tie-break sağlamak için;
 *    tamamen rastgele tie-break oyuncuların "hep aynı kişi öne geçiyor"
 *    hissine kapılmasını önler).
 */

import { Player } from "../models/Player";
import { shuffleArray } from "./spyDistribution";

/**
 * @param roundNumber 1-indexed tur numarası
 * @param players     Tüm oyuncular (güncel skorlarıyla)
 * @param previousTurnOrder Bir önceki turun sıralaması (tie-break için,
 *        round 1'de gerekmez)
 */
export function getTurnOrder(
  roundNumber: number,
  players: Player[],
  previousTurnOrder: string[] = []
): string[] {
  if (roundNumber <= 1) {
    return shuffleArray(players.map((p) => p.id));
  }

  const prevIndex = new Map(previousTurnOrder.map((id, idx) => [id, idx]));

  return [...players]
    .sort((a, b) => {
      if (a.score !== b.score) return a.score - b.score; // düşük puan önce
      // Eşitlik durumunda: önceki turdaki sırayı koru (stabil, adil).
      const ai = prevIndex.get(a.id) ?? Number.MAX_SAFE_INTEGER;
      const bi = prevIndex.get(b.id) ?? Number.MAX_SAFE_INTEGER;
      return ai - bi;
    })
    .map((p) => p.id);
}
