import { createPlayer, Player } from "../src/models/Player";
import { createWordPair, WordPack, DEFAULT_PACK_ID } from "../src/models/WordPack";
import { RoundPhase } from "../src/models/GameState";
import { GameEngine } from "../src/engine/GameEngine";
import { buildUnifiedWordPool } from "../src/engine/wordSelection";

function assert(cond: boolean, msg: string) {
  if (!cond) throw new Error("ASSERTION FAILED: " + msg);
  console.log("  OK  " + msg);
}

console.log("\n=== TEST: Oylama Eşitliği (Tie-Break) turnOrder'a Göre ===");

const players: Player[] = [
  createPlayer("A"),
  createPlayer("B"),
  createPlayer("C"),
  createPlayer("D"),
];

const pack: WordPack = {
  id: DEFAULT_PACK_ID,
  name: "Test",
  isCustom: false,
  isEditable: false,
  createdAt: Date.now(),
  updatedAt: Date.now(),
  pairs: [createWordPair("Kahve", "Çay", DEFAULT_PACK_ID)],
};
const pool = buildUnifiedWordPool([pack], [DEFAULT_PACK_ID]);

const engine = new GameEngine(
  players,
  { playerCount: 4, maxSpyRatio: 0.3, allowMixedMode: false, selectedPackIds: [DEFAULT_PACK_ID] },
  pool
);

const round = engine.startNewRound("BLACK_ONLY");
for (const pid of round.turnOrder) engine.confirmCardViewed(pid);
for (let i = 0; i < round.turnOrder.length; i++) engine.advanceDiscussionTurn();

// turnOrder'daki ilk iki oyuncuya eşit oy (2-2) verelim; kazanan turnOrder[0] olmalı.
const [p0, p1, p2, p3] = round.turnOrder;
engine.submitVote(p0, p0); // kendine oy (kural dışı değil, motor kontrol etmiyor)
engine.submitVote(p1, p0);
engine.submitVote(p2, p1);
engine.submitVote(p3, p1);

assert(round.phase === RoundPhase.REVEAL || round.phase === RoundPhase.WHITE_GUESS || round.phase === RoundPhase.RESULT,
  "Herkes oy verince faz ilerledi");
assert(round.eliminatedPlayerId === p0,
  `2-2 eşitliğinde turnOrder'da önce gelen (${p0}) elenmeli, gelen: ${round.eliminatedPlayerId}`);

console.log("\nTIE-BREAK TESTİ BAŞARILI ✅");
