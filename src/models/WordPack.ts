/**
 * WordPack.ts
 * -----------------------------------------------------------------------
 * Kelime çifti (Ana Kelime + Siyah Kelime) ve paket modeli.
 *
 * ÖNEMLİ: WordPack sadece DEPOLAMA/ORGANİZASYON birimidir (dahili paket,
 * kullanıcı paketi vb.). Oyun sırasında wordSelection.buildUnifiedWordPool
 * bu paketleri TEK BİR havuzda birleştirir — paket kimliği seçim
 * aşamasından sonra anlamını yitirir (tek blok kuralı, wordSelection.ts'te
 * belgelendi).
 */

export interface WordPair {
  id: string;
  mainWord: string;   // Ana Kart kelimesi (masumlara verilir)
  spyWord: string;    // Siyah Kart kelimesi (farklı ama çağrışımlı kelime)
  packId: string;      // Bu çiftin geldiği paket (sadece yönetim/düzenleme amaçlı)
}

export interface WordPack {
  id: string;
  name: string;
  isCustom: boolean;     // true: kullanıcı paketi, false: dahili kütüphane
  isEditable: boolean;   // dahili kütüphane düzenlenemez (isEditable=false)
  createdAt: number;
  updatedAt: number;
  pairs: WordPair[];
}

export const DEFAULT_PACK_ID = "default_builtin_pack";

let pairCounter = 0;

function generatePairId(): string {
  pairCounter += 1;
  const rand = Math.random().toString(36).slice(2, 8);
  return `pair_${Date.now().toString(36)}_${pairCounter}_${rand}`;
}

/**
 * Yeni bir WordPair oluşturur. mainWord ve spyWord aynı olamaz
 * (aksi halde casus ile masum arasında fark kalmaz).
 */
export function createWordPair(
  mainWord: string,
  spyWord: string,
  packId: string
): WordPair {
  const main = mainWord.trim();
  const spy = spyWord.trim();
  if (main.length === 0 || spy.length === 0) {
    throw new Error("Ana kelime ve siyah kelime boş olamaz.");
  }
  if (main.toLocaleLowerCase("tr-TR") === spy.toLocaleLowerCase("tr-TR")) {
    throw new Error(
      `Ana kelime ile siyah kelime aynı olamaz ("${main}"). Casus kartı ` +
        "ancak farklı bir kelimeyle anlamlıdır."
    );
  }
  return {
    id: generatePairId(),
    mainWord: main,
    spyWord: spy,
    packId,
  };
}

/** Yeni (boş) bir kullanıcı paketi oluşturur. */
export function createUserWordPack(name: string): WordPack {
  const trimmed = name.trim();
  if (trimmed.length === 0) {
    throw new Error("Paket adı boş olamaz.");
  }
  const now = Date.now();
  return {
    id: `pack_${now.toString(36)}_${Math.random().toString(36).slice(2, 8)}`,
    name: trimmed,
    isCustom: true,
    isEditable: true,
    createdAt: now,
    updatedAt: now,
    pairs: [],
  };
}
