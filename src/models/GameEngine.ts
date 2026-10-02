/**
 * GameEngine.ts
 * -----------------------------------------------------------------------
 * Oyunun merkezi state machine'i. Tüm faz geçişleri (Dealing -> Discussion
 * -> Voting -> Reveal -> [White Guess] -> Result) burada yönetilir.
 *
 * TASARIM NOTU: Bu sınıf, oyuncu skorlarını (`Player.score`) doğrudan
 * mutasyonla günceller (basitlik için). Eğer UI katmanı Redux/Zustand gibi
 * immutable bir state yönetimi kullanacaksa, bu sınıfı bir "pure reducer"
 * katmanına sarmalamak (her metottan yeni bir GameState/Player[] döndürmek)
 * kolaydır — iş mantığı burada zaten metotlara izole edilmiş durumda.
 * Adım 3'te (UI) hangi state yönetim yaklaşımını kullanacağımıza karar
 * verip gerekirse bu köprüyü kuracağız.
 *
 * HATA YÖNETİMİ: Yanlış fazda çağrılan metotlar (örn. VOTING fazındayken
 * submitWhiteCardGuess çağrılması) açık bir Error fırlatır — bu, UI
 * katmanının state machine kurallarını yanlışlıkla ihlal etmesini erken
 * yakalamak içindir.
 */

import { Player } from "../models/Player";
import { WordPair } from "../models/WordPack";
import {
  CardType,
  CardAssignment,
  buildAssignments,
} from "../models/CardAssignment";
import {
  GameState,
  GameSettings,
  RoundState,
  RoundPhase,
} from "../models/GameState";
import {
  calculateSpyDistribution,
  pickSpyPlayers,
  SpyModePreference,
} from "./spyDistribution";
import { getTurnOrder } from "./turnOrder";
import { pickNextWordPair } from "./wordSelection";

// --- Puanlama sabitleri (tek yerde toplanmış, kolayca ayarlanabilir) ---
export const SCORE_INNOCENT_WIN = 1;      // Masumlar kazanınca her masum +1
export const SCORE_SPY_WIN = 2;           // Casus(lar) kazanınca her casus +2
export const SCORE_WHITE_SOLO_WIN = 3;    // Beyaz kart tek başına kazanınca +3

export class GameEngine {
  private state: GameState;
  private players: Map<string, Player>;
  private wordPool: WordPair[];
  private usedPairIds: Set<string> = new Set();

  constructor(
    players: Player[],
    settings: GameSettings,
    wordPool: WordPair[]
  ) {
    this.players = new Map(players.map((p) => [p.id, p]));
    this.wordPool = wordPool;
    this.state = {
      settings,
      players: players.map((p) => p.id),
      rounds: [],
      currentRoundIndex: -1,
      status: "SETUP",
    };
  }

  getState(): GameState {
    return this.state;
  }

  getPlayer(playerId: string): Player {
    const player = this.players.get(playerId);
    if (!player) throw new Error(`Bilinmeyen oyuncu id: ${playerId}`);
    return player;
  }

  getCurrentRound(): RoundState {
    const round = this.state.rounds[this.state.currentRoundIndex];
    if (!round) throw new Error("Aktif bir tur yok. startNewRound() çağırın.");
    return round;
  }

  private assertPhase(expected: RoundPhase) {
    const round = this.getCurrentRound();
    if (round.phase !== expected) {
      throw new Error(
        `Geçersiz faz: '${expected}' bekleniyordu, mevcut faz '${round.phase}'.`
      );
    }
  }

  // -----------------------------------------------------------------
  // 1) TUR BAŞLATMA (SETUP -> DEALING)
  // -----------------------------------------------------------------
  startNewRound(spyPreference: SpyModePreference = "RANDOM"): RoundState {
    const roundNumber = this.state.rounds.length + 1;
    const allPlayers = [...this.players.values()];
    const playerIds = allPlayers.map((p) => p.id);

    const wordPair = pickNextWordPair(this.wordPool, this.usedPairIds);
    this.usedPairIds.add(wordPair.id);

    const distribution = calculateSpyDistribution(
      playerIds.length,
      spyPreference,
      this.state.settings.maxSpyRatio
    );
    const { blackCardPlayerIds, whiteCardPlayerIds } = pickSpyPlayers(
      playerIds,
      distribution
    );

    const assignments: CardAssignment[] = buildAssignments(
      playerIds,
      wordPair.mainWord,
      wordPair.spyWord,
      blackCardPlayerIds,
      whiteCardPlayerIds
    );

    const previousRound = this.state.rounds[this.state.rounds.length - 1];
    const turnOrder = getTurnOrder(
      roundNumber,
      allPlayers,
      previousRound?.turnOrder ?? []
    );

    const round: RoundState = {
      roundNumber,
      wordPair,
      assignments,
      turnOrder,
      currentTurnIndex: 0,
      phase: RoundPhase.DEALING,
      spyCount: { black: distribution.blackCount, white: distribution.whiteCount },
      votes: {},
    };

    this.state.rounds.push(round);
    this.state.currentRoundIndex = this.state.rounds.length - 1;
    this.state.status = "IN_PROGRESS";
    return round;
  }

  // -----------------------------------------------------------------
  // 2) DEALING FAZI — Pass & Play kart görüntüleme sırası
  // -----------------------------------------------------------------

  /** Sırası gelen oyuncunun id'sini döner ("Telefonu X'e verin" ekranı için). */
  getPlayerAwaitingCardView(): string {
    this.assertPhase(RoundPhase.DEALING);
    const round = this.getCurrentRound();
    return round.turnOrder[round.currentTurnIndex];
  }

  /** İlgili oyuncunun kartını görüntülediğini/onayladığını işaretler ve sırayı ilerletir. */
  confirmCardViewed(playerId: string): void {
    this.assertPhase(RoundPhase.DEALING);
    const round = this.getCurrentRound();
    const expectedPlayerId = round.turnOrder[round.currentTurnIndex];
    if (playerId !== expectedPlayerId) {
      throw new Error(
        `Sıra bu oyuncuda değil. Beklenen: ${expectedPlayerId}, gelen: ${playerId}`
      );
    }
    const assignment = round.assignments.find((a) => a.playerId === playerId);
    if (assignment) assignment.hasViewed = true;

    round.currentTurnIndex++;
    if (round.currentTurnIndex >= round.turnOrder.length) {
      // Herkes kartını gördü -> tartışma fazına geç.
      round.phase = RoundPhase.DISCUSSION;
      round.currentTurnIndex = 0;
    }
  }

  // -----------------------------------------------------------------
  // 3) DISCUSSION FAZI — ipucu söyleme sırası
  // -----------------------------------------------------------------

  getPlayerAwaitingClue(): string {
    this.assertPhase(RoundPhase.DISCUSSION);
    const round = this.getCurrentRound();
    return round.turnOrder[round.currentTurnIndex];
  }

  /** Bir sonraki oyuncuya geçer. Herkes ipucunu söyledikten sonra VOTING fazına geçilir. */
  advanceDiscussionTurn(): void {
    this.assertPhase(RoundPhase.DISCUSSION);
    const round = this.getCurrentRound();
    round.currentTurnIndex++;
    if (round.currentTurnIndex >= round.turnOrder.length) {
      round.phase = RoundPhase.VOTING;
    }
  }

  // -----------------------------------------------------------------
  // 4) VOTING FAZI
  // -----------------------------------------------------------------

  submitVote(voterId: string, votedPlayerId: string): void {
    this.assertPhase(RoundPhase.VOTING);
    const round = this.getCurrentRound();
    round.votes[voterId] = votedPlayerId;

    const allVoted = round.turnOrder.every((id) => round.votes[id] !== undefined);
    if (allVoted) {
      round.eliminatedPlayerId = this.tallyVotes(round.votes);
      round.phase = RoundPhase.REVEAL;
    }
  }

  /** En çok oyu alan oyuncuyu döner. Eşitlik durumunda ilk sıradaki (turnOrder) tercih edilir. */
  private tallyVotes(votes: Record<string, string>): string {
    const counts = new Map<string, number>();
    for (const votedId of Object.values(votes)) {
      counts.set(votedId, (counts.get(votedId) ?? 0) + 1);
    }
    let winner = "";
    let maxVotes = -1;
    for (const [playerId, count] of counts) {
      if (count > maxVotes) {
        maxVotes = count;
        winner = playerId;
      }
    }
    return winner;
  }

  // -----------------------------------------------------------------
  // 5) REVEAL FAZI — oylanan oyuncunun kartı açığa çıkar
  // -----------------------------------------------------------------

  /**
   * Reveal sonucunu işler:
   *  - Elenen MAIN ise -> Casus(lar) kazanır, tur biter.
   *  - Elenen BLACK ise -> Masumlar kazanır, tur biter.
   *  - Elenen WHITE ise -> WHITE_GUESS fazına geçilir (özel kural).
   */
  resolveReveal(): RoundState {
    this.assertPhase(RoundPhase.REVEAL);
    const round = this.getCurrentRound();
    const eliminated = this.getAssignment(round, round.eliminatedPlayerId!);

    if (eliminated.cardType === CardType.WHITE) {
      round.phase = RoundPhase.WHITE_GUESS;
      return round;
    }

    if (eliminated.cardType === CardType.BLACK) {
      round.winner = "INNOCENTS";
    } else {
      // MAIN kart sahibi yanlışlıkla elendi -> casuslar kazandı.
      round.winner = "SPIES";
    }
    this.applyScoring(round);
    round.phase = RoundPhase.RESULT;
    return round;
  }

  private getAssignment(round: RoundState, playerId: string): CardAssignment {
    const assignment = round.assignments.find((a) => a.playerId === playerId);
    if (!assignment) throw new Error(`Atama bulunamadı: ${playerId}`);
    return assignment;
  }

  // -----------------------------------------------------------------
  // 6) WHITE_GUESS FAZI — özel Beyaz Kart kuralı
  // -----------------------------------------------------------------

  submitWhiteCardGuess(playerId: string, guessedWord: string): RoundState {
    this.assertPhase(RoundPhase.WHITE_GUESS);
    const round = this.getCurrentRound();

    if (round.eliminatedPlayerId !== playerId) {
      throw new Error(
        "Sadece elenen Beyaz Kart sahibi ana kelimeyi tahmin edebilir."
      );
    }

    const isCorrect =
      normalize(guessedWord) === normalize(round.wordPair.mainWord);

    round.whiteCardGuess = { playerId, guessedWord, isCorrect };
    round.winner = isCorrect ? "WHITE_CARD_SOLO" : "SPIES";

    this.applyScoring(round);
    round.phase = RoundPhase.RESULT;
    return round;
  }

  // -----------------------------------------------------------------
  // 7) PUANLAMA (RESULT fazına geçerken bir kez uygulanır)
  // -----------------------------------------------------------------

  private applyScoring(round: RoundState): void {
    switch (round.winner) {
      case "INNOCENTS": {
        for (const a of round.assignments) {
          if (a.cardType === CardType.MAIN) {
            this.getPlayer(a.playerId).score += SCORE_INNOCENT_WIN;
          }
        }
        break;
      }
      case "SPIES": {
        for (const a of round.assignments) {
          if (a.cardType === CardType.BLACK || a.cardType === CardType.WHITE) {
            this.getPlayer(a.playerId).score += SCORE_SPY_WIN;
          }
        }
        break;
      }
      case "WHITE_CARD_SOLO": {
        const guesserId = round.whiteCardGuess!.playerId;
        this.getPlayer(guesserId).score += SCORE_WHITE_SOLO_WIN;
        break;
      }
    }
  }

  // -----------------------------------------------------------------
  // 8) TUR SONU — bir sonraki tura geçmeye hazırlık
  // -----------------------------------------------------------------

  /** RESULT fazındaki mevcut turu kapatır; oyun devam ediyorsa true döner. */
  finishRound(): boolean {
    this.assertPhase(RoundPhase.RESULT);
    // İleride "oyunu bitir" koşulları (örn. hedef skora ulaşma) buraya eklenebilir.
    return true;
  }

  endGame(): void {
    this.state.status = "FINISHED";
  }
}

function normalize(word: string): string {
  return word.trim().toLocaleLowerCase("tr-TR");
}
