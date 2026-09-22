/**
 * Player.ts
 * -----------------------------------------------------------------------
 * Oyuncu modeli. GameEngine ve turnOrder bu arayüze güvenir.
 */

export interface Player {
  id: string;
  name: string;
  score: number;
}

let playerCounter = 0;

/** Basit, çakışmasız bir id üretir (timestamp + artan sayaç + random). */
function generateId(prefix: string): string {
  playerCounter += 1;
  const rand = Math.random().toString(36).slice(2, 8);
  return `${prefix}_${Date.now().toString(36)}_${playerCounter}_${rand}`;
}

/**
 * Yeni bir oyuncu oluşturur. Skor her zaman 0'dan başlar.
 * İsim baştaki/sondaki boşluklardan arındırılır; boş isim kabul edilmez.
 */
export function createPlayer(name: string): Player {
  const trimmed = name.trim();
  if (trimmed.length === 0) {
    throw new Error("Oyuncu adı boş olamaz.");
  }
  return {
    id: generateId("player"),
    name: trimmed,
    score: 0,
  };
}
