/**
 * GameState.ts
 * -----------------------------------------------------------------------
 * GameEngine'in yönettiği state machine'in veri şekli.
 *
 * Faz akışı:
 *   DEALING -> DISCUSSION -> VOTING -> REVEAL -> [WHITE_GUESS] -> RESULT
 */

import { CardAssignment } from "./CardAssignment";
import { WordPair } from "./WordPack";

export enum RoundPhase {
  DEALING = "DEALING",
  DISCUSSION = "DISCUSSION",
  VOTING = "VOTING",
  REVEAL = "REVEAL",
  WHITE_GUESS = "WHITE_GUESS",
  RESULT = "RESULT",
}

export type RoundWinner = "INNOCENTS" | "SPIES" | "WHITE_CARD_SOLO";

export interface WhiteCardGuess {
  playerId: string;
  guessedWord: string;
  isCorrect: boolean;
}

export interface RoundState {
  roundNumber: number;
  wordPair: WordPair;
  assignments: CardAssignment[];
  turnOrder: string[]; // playerId dizisi (o turun kart bakma/konuşma sırası)
  currentTurnIndex: number;
  phase: RoundPhase;
  spyCount: { black: number; white: number };
  votes: Record<string, string>; // voterId -> votedPlayerId
  eliminatedPlayerId?: string;
  winner?: RoundWinner;
  whiteCardGuess?: WhiteCardGuess;
}

export interface GameSettings {
  playerCount: number;
  maxSpyRatio: number; // varsayılan 0.30
  allowMixedMode: boolean;
  selectedPackIds: string[]; // dahili + kullanıcı paketlerinden seçilenler
}

export type GameStatus = "SETUP" | "IN_PROGRESS" | "FINISHED";

export interface GameState {
  settings: GameSettings;
  players: string[]; // playerId dizisi
  rounds: RoundState[];
  currentRoundIndex: number;
  status: GameStatus;
}
