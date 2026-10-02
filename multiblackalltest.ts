import { createPlayer, Player } from "../src/models/Player";
import { createWordPair, WordPack, DEFAULT_PACK_ID } from "../src/models/WordPack";
import { CardType } from "../src/models/CardAssignment";
import { RoundPhase } from "../src/models/GameState";
import { GameEngine, SCORE_INNOCENT_WIN } from "../src/engine/GameEngine";
import { buildUnifiedWordPool } from "../src/engine/wordSelection";

function assert(cond: boolean, msg: string) {
  if (!cond) throw new Error("ASSERTION FAILED: " + msg);
  console.log("  OK  " + msg);
}

console.log("\n=== TEST: Çoklu BLACK — İkisi de yakalanınca INNOCENTS kazanır ===");

const players: Player[] = Array.from({ length: 10 }, (_, i) => createPlayer(`P${i + 1}`));
const pack: WordPack = {
  id: DEFAULT_PACK_ID, name: "Test", isCustom: false, isEditable: false,
  createdAt: Date.now(), updatedAt: Date.now(),
  pairs: [createWordPair("Kahve", "Çay", DEFAULT_PACK_ID)],
};
const pool = buildUnifiedWordPool([pack], [DEFAULT_PACK_ID]);

// n=10 -> maxSpies = floor(10*0.3) = 3, yani BLACK_ONLY 2 veya 3 casus atayabilir.
// Testi kaç casus atandığına bakmaksızın dinamik çalıştırıyoruz (varsayım hatasından kaçınmak için).
let engine: GameEngine, round;
let blacks: string[] = [];
do {
  engine = new GameEngine(players, { playerCount: 10, maxSpyRatio: 0.3, allowMixedMode: true, selectedPackIds: [DEFAULT_PACK_ID] }, pool);
  round = engine.startNewRound("BLACK_ONLY");
  blacks = round.assignments.filter((a) => a.cardType === CardType.BLACK).map((a) => a.playerId);
} while (blacks.length < 2); // en az 2 casus olan bir tur bul (çoklu-yakalama senaryosu için)

assert(blacks.length >= 2, `En az 2 BLACK casus atandı (gerçek: ${blacks.length})`);
console.log(`  (bilgi) bu turda toplam ${blacks.length} BLACK casus var`);

for (const pid of round.turnOrder) engine.confirmCardViewed(pid);

// Casusları BİRER BİRER, her seferinde bir tanesini oylayarak yakala.
// Son casus yakalanana kadar tur DISCUSSION'a dönmeye devam etmeli;
// son casus yakalandığında RESULT'a (INNOCENTS) geçmeli.
for (let round_i = 0; round_i < blacks.length; round_i++) {
  for (let i = 0; i < round.activeOrder.length; i++) engine.advanceDiscussionTurn();
  assert(round.phase === RoundPhase.VOTING, `Döngü ${round_i + 1}: VOTING fazına geçildi`);

  const target = blacks[round_i];
  const decoy = round.activeOrder.find((id: string) => id !== target)!;
  for (const voterId of round.activeOrder) {
    engine.submitVote(voterId, voterId === target ? decoy : target);
  }
  assert(round.eliminatedPlayerId === target, `Döngü ${round_i + 1}: doğru BLACK (${target}) en çok oyu aldı`);
  engine.resolveReveal();

  const isLast = round_i === blacks.length - 1;
  if (isLast) {
    assert(round.phase === RoundPhase.RESULT, "Son casus da yakalandı -> RESULT fazına geçildi");
    assert(round.winner === "INNOCENTS", "Tüm casuslar bulundu -> INNOCENTS kazandı");
  } else {
    assert(round.phase === RoundPhase.DISCUSSION, `Döngü ${round_i + 1}: hâlâ gizli casus var -> tur devam ediyor`);
    assert(round.winner === undefined, `Döngü ${round_i + 1}: winner henüz atanmadı`);
  }
}

const innocentSample = players.find((p) => !blacks.includes(p.id))!;
assert(innocentSample.score === SCORE_INNOCENT_WIN, "Masum oyuncular doğru puanlandı");

console.log("\nÇOKLU BLACK TESTİ BAŞARILI ✅");