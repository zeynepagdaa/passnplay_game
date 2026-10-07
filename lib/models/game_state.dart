

import 'card_assignment.dart';
import 'word_pack.dart';

enum RoundPhase { dealing, discussion, voting, reveal, whiteGuess, result }

enum RoundWinner { innocents, spies, whiteCardSolo }

class WhiteCardGuess {
  final String playerId;
  final String guessedWord;
  final bool isCorrect;

  WhiteCardGuess({
    required this.playerId,
    required this.guessedWord,
    required this.isCorrect,
  });
}

class SpyCount {
  final int black;
  final int white;
  const SpyCount({required this.black, required this.white});
}

class RoundState {
  final int roundNumber;
  final WordPair wordPair;
  final List<CardAssignment> assignments;
  final List<String> turnOrder; // SABİT kart bakma sırası (DEALING için)
  List<String> activeOrder; // AKTİF (henüz elenmemiş) oyuncular — Karma Mod devam kuralı
  int currentTurnIndex;
  RoundPhase phase;
  final SpyCount spyCount;
  Map<String, String> votes; // voterId -> votedPlayerId
  String? eliminatedPlayerId; // bu döngüde EN SON reveal edilen oyuncu
  final List<String> eliminatedPlayerIds; // tur boyunca elenen TÜM oyuncular (kronolojik)
  RoundWinner? winner;
  WhiteCardGuess? whiteCardGuess;

  RoundState({
    required this.roundNumber,
    required this.wordPair,
    required this.assignments,
    required this.turnOrder,
    required this.activeOrder,
    this.currentTurnIndex = 0,
    this.phase = RoundPhase.dealing,
    required this.spyCount,
    Map<String, String>? votes,
    this.eliminatedPlayerId,
    List<String>? eliminatedPlayerIds,
    this.winner,
    this.whiteCardGuess,
  })  : votes = votes ?? {},
        eliminatedPlayerIds = eliminatedPlayerIds ?? [];
}

class GameSettings {
  final int playerCount;
  final double maxSpyRatio; // varsayılan 0.30
  final bool allowMixedMode;
  final List<String> selectedPackIds; // dahili + kullanıcı paketlerinden seçilenler

  const GameSettings({
    required this.playerCount,
    this.maxSpyRatio = 0.3,
    this.allowMixedMode = true,
    required this.selectedPackIds,
  });
}

enum GameStatus { setup, inProgress, finished }

class GameState {
  final GameSettings settings;
  final List<String> players; // playerId dizisi
  final List<RoundState> rounds;
  int currentRoundIndex;
  GameStatus status;

  GameState({
    required this.settings,
    required this.players,
    List<RoundState>? rounds,
    this.currentRoundIndex = -1,
    this.status = GameStatus.setup,
  }) : rounds = rounds ?? [];
}