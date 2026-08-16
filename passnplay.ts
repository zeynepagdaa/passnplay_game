import { createPlayer, Player } from "../src/models/Player";
import { createWordPair, WordPack, DEFAULT_PACK_ID } from "../src/models/WordPack";
import { CardType } from "../src/models/CardAssignment";
import { RoundPhase } from "../src/models/GameState";
import { GameEngine, SCORE_INNOCENT_WIN } from "../src/engine/GameEngine";
import { getMaxSpyCount, calculateSpyDistribution } from "../src/engine/spyDistribution";
import { buildUnifiedWordPool } from "../src/engine/wordSelection";

function assert(cond: boolean, msg: string) {
  if (!cond) throw new Error("ASSERTION FAILED: " + msg);
  console.log("  OK  " + msg);
}

// ------------------------------------------------------------------
// TEST 1: %30 kuralı — geniş bir oyuncu aralığında binlerce deneme
// ------------------------------------------------------------------
console.log("\n=== TEST 1: %30 Casus Sınırı Doğrulaması ===");
for (let n = 3; n <= 20; n++) {
  const maxAllowed = Math.floor(n * 0.3);
  const effectiveMax = Math.max(1, maxAllowed);
  for (let trial = 0; trial < 500; trial++) {
    const dist = calculateSpyDistribution(n, "RANDOM");
    if (dist.total > effectiveMax) {
      throw new Error(
        `ASSERTION FAILED: n=${n} icin total=${dist.total} > izinliMax=${effectiveMax}`
      );
    }
    if (n < 6 && dist.total !== 1) {
      throw new Error(`ASSERTION FAILED: n=${n} (<6) icin total spy 1 olmali, geldi: ${dist.total}`);
    }
  }
}
console.log(`  OK  n=3..20 arasi, her n icin 500 deneme, cap hicbir zaman asilmadi`);
console.log(`  OK  n<6 icin daima tam 1 casus`);

// n=7 icin karma modun matematiksel olarak mumkun oldugunu dogrula
let sawMixedAt7 = false;
for (let i = 0; i < 200; i++) {
  const d = calculateSpyDistribution(7, "MIXED");
  if (d.blackCount > 0 && d.whiteCount > 0) sawMixedAt7 = true;
  assert(d.total <= getMaxSpyCount(7), `n=7 MIXED denemesi cap'i asmadi (total=${d.total})`);
}
assert(sawMixedAt7, "n=7, MIXED preference ile en az bir kez hem Siyah hem Beyaz kart uretildi");

// ------------------------------------------------------------------
// TEST 2: Tam bir round'u state machine uzerinden bastan sona oynat
// ------------------------------------------------------------------
console.log("\n=== TEST 2: Uctan Uca Round Akisi (Dealing -> ... -> Result) ===");

const players: Player[] = [
  createPlayer("Ayşe"),
  createPlayer("Mehmet"),
  createPlayer("Zeynep"),
  createPlayer("Ali"),
  createPlayer("Fatma"),
];

const pack: WordPack = {
  id: DEFAULT_PACK_ID,
  name: "Varsayilan",
  isCustom: false,
  isEditable: false,
  createdAt: Date.now(),
  updatedAt: Date.now(),
  pairs: [
    createWordPair("Kahve", "Çay", DEFAULT_PACK_ID),
    createWordPair("Deniz", "Göl", DEFAULT_PACK_ID),
  ],
};
const pool = buildUnifiedWordPool([pack], [DEFAULT_PACK_ID]);

const engine = new GameEngine(
  players,
  { playerCount: players.length, maxSpyRatio: 0.3, allowMixedMode: true, selectedPackIds: [DEFAULT_PACK_ID] },
  pool
);

const round = engine.startNewRound("RANDOM");
assert(round.phase === RoundPhase.DEALING, "Round DEALING fazinda basladi");
assert(round.spyCount.black + round.spyCount.white === 1, "5 oyuncuda tam 1 casus var (n<6 kurali)");

// MAIN ve BLACK kartlarin UI'a ayni sekilde gorunmesi gereken kural: her ikisinde de word dolu olmali
const mainOrBlack = round.assignments.filter(a => a.cardType !== CardType.WHITE);
assert(mainOrBlack.every(a => typeof a.word === "string" && a.word.length > 0),
  "MAIN ve BLACK kartlarin hepsinde word alani dolu (UI ayrimi yapilamaz)");
const whiteAssignments = round.assignments.filter(a => a.cardType === CardType.WHITE);
assert(whiteAssignments.every(a => a.word === null), "WHITE kartlarda word=null");

// Dealing: herkes sirayla karti gorsun
for (const pid of round.turnOrder) {
  assert(engine.getPlayerAwaitingCardView() === pid, `Sira oyuncu ${pid} icin dogru`);
  engine.confirmCardViewed(pid);
}
assert(round.phase === RoundPhase.DISCUSSION, "Herkes karti gordukten sonra DISCUSSION fazina gecildi");

// Discussion: herkes ipucu versin (turn ilerlet)
for (let i = 0; i < round.turnOrder.length; i++) {
  engine.advanceDiscussionTurn();
}
assert(round.phase === RoundPhase.VOTING, "Discussion bitince VOTING fazina gecildi");

// Voting: BLACK ya da WHITE kart sahibini bulup herkesi ona oylatalim (Masumlar kazansin senaryosu)
const spyAssignment = round.assignments.find(a => a.cardType !== CardType.MAIN)!;
for (const voterId of round.turnOrder) {
  engine.submitVote(voterId, spyAssignment.playerId);
}
assert(round.phase === RoundPhase.REVEAL || round.phase === RoundPhase.RESULT || round.phase === RoundPhase.WHITE_GUESS,
  "Herkes oy verince REVEAL/sonraki faza gecildi");
assert(round.eliminatedPlayerId === spyAssignment.playerId, "Oylamada en cok oy alan casus dogru tespit edildi");

if (round.phase === RoundPhase.REVEAL) {
  engine.resolveReveal();
}

if (spyAssignment.cardType === CardType.WHITE) {
  assert(round.phase === RoundPhase.WHITE_GUESS, "Beyaz kart yakalandi -> WHITE_GUESS fazina gecildi");
  // Yanlis tahmin senaryosu
  engine.submitWhiteCardGuess(spyAssignment.playerId, "yanlis-kelime-xyz");
  assert(round.winner === "SPIES", "Beyaz kart yanlis tahmin edince SPIES kazanir");
} else {
  assert(round.phase === RoundPhase.RESULT, "Siyah kart yakalaninca dogrudan RESULT fazina gecildi");
  assert(round.winner === "INNOCENTS", "Siyah kart (farkli kart) doğru bulununca Masumlar kazanir");
  const innocentPlayer = players.find(p => p.id !== spyAssignment.playerId)!;
  assert(innocentPlayer.score === SCORE_INNOCENT_WIN, "Masum oyuncunun skoru dogru arttirildi");
}

console.log("\nTUM TESTLER BASARILI ✅");
