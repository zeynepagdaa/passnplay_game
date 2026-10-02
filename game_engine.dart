/// game_engine.dart
/// -----------------------------------------------------------------------
/// Oyunun merkezi state machine'i. Tüm faz geçişleri burada yönetilir:
///
///   DEALING -> DISCUSSION -> VOTING -> REVEAL
///     -> (BLACK yakalandı, hâlâ gizli casus var) -> DISCUSSION (yeni döngü)
///     -> (BLACK yakalandı, tüm casuslar bulundu) -> RESULT (INNOCENTS)
///     -> (WHITE yakalandı) -> WHITE_GUESS -> RESULT
///     -> (MAIN yanlışlıkla elendi) -> RESULT (SPIES)
///
/// KARMA MOD DEVAM KURALI (kullanıcı onaylı tasarım kararı):
/// Bir turda hem Siyah hem Beyaz kart varsa ve oylamada sadece biri
/// yakalanırsa, tur BİTMEZ. Yakalanan casus `activeOrder`dan çıkarılır
/// (artık oy kullanamaz/oylanamaz) ve tartışma/oylama, hâlâ gizli casus
/// kalmayana ya da bir masum yanlışlıkla elenene kadar devam eder.
///
/// PUANLAMA NOTU: SPIES kazandığında, bu turda DAHA ÖNCE (Karma Mod
/// döngüsünde) yakalanmış bir casus artık "bulunmuş" sayılır ve puan
/// almaz — sadece sona kadar tespit edilemeyen casuslar ödüllendirilir.
///
/// HATA YÖNETİMİ: Yanlış fazda çağrılan metotlar açık bir StateError
/// fırlatır (UI'ın state machine kurallarını yanlışlıkla ihlal etmesini
/// erken yakalamak için).

import '../models/player.dart';
import '../models/word_pack.dart';
import '../models/card_assignment.dart';
import '../models/game_state.dart';
import 'spy_distribution.dart';
import 'turn_order.dart';
import 'word_selection.dart';

// --- Puanlama sabitleri ---
const int scoreInnocentWin = 1; // Masumlar kazanınca her masum +1
const int scoreSpyWin = 2; // Casus(lar) kazanınca (sona kadar gizli kalan) her casus +2
const int scoreWhiteSoloWin = 3; // Beyaz kart tek başına kazanınca +3

class GameEngine {
  late final GameState _state;
  final Map<String, Player> _players;
  final List<WordPair> _wordPool;
  final Set<String> _usedPairIds = {};

  GameEngine(List<Player> players, GameSettings settings, List<WordPair> wordPool)
      : _players = {for (final p in players) p.id: p},
        _wordPool = wordPool {
    _state = GameState(
      settings: settings,
      players: players.map((p) => p.id).toList(),
    );
  }

  GameState getState() => _state;

  Player getPlayer(String playerId) {
    final player = _players[playerId];
    if (player == null) throw StateError('Bilinmeyen oyuncu id: $playerId');
    return player;
  }

  RoundState getCurrentRound() {
    if (_state.currentRoundIndex < 0 ||
        _state.currentRoundIndex >= _state.rounds.length) {
      throw StateError('Aktif bir tur yok. startNewRound() çağırın.');
    }
    return _state.rounds[_state.currentRoundIndex];
  }

  void _assertPhase(RoundPhase expected) {
    final round = getCurrentRound();
    if (round.phase != expected) {
      throw StateError(
          "Geçersiz faz: '$expected' bekleniyordu, mevcut faz '${round.phase}'.");
    }
  }

  // -----------------------------------------------------------------
  // 1) TUR BAŞLATMA (SETUP -> DEALING)
  // -----------------------------------------------------------------
  RoundState startNewRound({SpyModePreference spyPreference = SpyModePreference.random}) {
    final roundNumber = _state.rounds.length + 1;
    final allPlayers = _players.values.toList();
    final playerIds = allPlayers.map((p) => p.id).toList();

    final wordPair = pickNextWordPair(_wordPool, _usedPairIds);
    _usedPairIds.add(wordPair.id);

    final distribution = calculateSpyDistribution(
      playerIds.length,
      preference: spyPreference,
      maxSpyRatio: _state.settings.maxSpyRatio,
    );
    final selection = pickSpyPlayers(playerIds, distribution);

    final assignments = buildAssignments(
      playerIds,
      wordPair.mainWord,
      wordPair.spyWord,
      selection.blackCardPlayerIds,
      selection.whiteCardPlayerIds,
    );

    final previousRound = _state.rounds.isNotEmpty ? _state.rounds.last : null;
    final turnOrder = getTurnOrder(
      roundNumber,
      allPlayers,
      previousTurnOrder: previousRound?.turnOrder ?? const [],
    );

    final round = RoundState(
      roundNumber: roundNumber,
      wordPair: wordPair,
      assignments: assignments,
      turnOrder: turnOrder,
      activeOrder: List<String>.from(turnOrder),
      spyCount: SpyCount(black: distribution.blackCount, white: distribution.whiteCount),
    );

    _state.rounds.add(round);
    _state.currentRoundIndex = _state.rounds.length - 1;
    _state.status = GameStatus.inProgress;
    return round;
  }

  // -----------------------------------------------------------------
  // 2) DEALING FAZI — Pass & Play kart görüntüleme sırası
  // -----------------------------------------------------------------

  /// Sırası gelen oyuncunun id'sini döner ("Telefonu X'e verin" ekranı için).
  String getPlayerAwaitingCardView() {
    _assertPhase(RoundPhase.dealing);
    final round = getCurrentRound();
    return round.turnOrder[round.currentTurnIndex];
  }

  /// İlgili oyuncunun kartını görüntülediğini işaretler ve sırayı ilerletir.
  void confirmCardViewed(String playerId) {
    _assertPhase(RoundPhase.dealing);
    final round = getCurrentRound();
    final expected = round.turnOrder[round.currentTurnIndex];
    if (playerId != expected) {
      throw StateError('Sıra bu oyuncuda değil. Beklenen: $expected, gelen: $playerId');
    }
    final assignment = round.assignments.firstWhere((a) => a.playerId == playerId);
    assignment.hasViewed = true;

    round.currentTurnIndex++;
    if (round.currentTurnIndex >= round.turnOrder.length) {
      round.phase = RoundPhase.discussion;
      round.currentTurnIndex = 0;
    }
  }

  // -----------------------------------------------------------------
  // 3) DISCUSSION FAZI — ipucu söyleme sırası (activeOrder üzerinden)
  // -----------------------------------------------------------------

  String getPlayerAwaitingClue() {
    _assertPhase(RoundPhase.discussion);
    final round = getCurrentRound();
    return round.activeOrder[round.currentTurnIndex];
  }

  /// Bir sonraki oyuncuya geçer. Herkes ipucunu söyledikten sonra VOTING'e geçilir.
  void advanceDiscussionTurn() {
    _assertPhase(RoundPhase.discussion);
    final round = getCurrentRound();
    round.currentTurnIndex++;
    if (round.currentTurnIndex >= round.activeOrder.length) {
      round.phase = RoundPhase.voting;
      round.currentTurnIndex = 0;
    }
  }

  // -----------------------------------------------------------------
  // 4) VOTING FAZI
  // -----------------------------------------------------------------

  /// Sadece hâlâ AKTİF (bu tur içinde daha önce elenmemiş) oyuncular oy
  /// kullanabilir ve oylanabilir.
  void submitVote(String voterId, String votedPlayerId) {
    _assertPhase(RoundPhase.voting);
    final round = getCurrentRound();

    if (!round.activeOrder.contains(voterId)) {
      throw StateError('Elenen oyuncu ($voterId) oy kullanamaz.');
    }
    if (!round.activeOrder.contains(votedPlayerId)) {
      throw StateError('Elenen oyuncu ($votedPlayerId) oylanamaz.');
    }

    round.votes[voterId] = votedPlayerId;

    final allVoted = round.activeOrder.every((id) => round.votes.containsKey(id));
    if (allVoted) {
      round.eliminatedPlayerId = _tallyVotes(round.votes, round.activeOrder);
      round.phase = RoundPhase.reveal;
    }
  }

  /// En çok oyu alan oyuncuyu döner. Eşitlik durumunda `activeOrder`
  /// içinde daha ÖNCE gelen oyuncu tercih edilir (oy verme sırasına göre
  /// DEĞİL — bu, TS prototipinde bulunup düzeltilen bir hatanın Dart
  /// tarafında baştan doğru yazılmış hâlidir).
  String _tallyVotes(Map<String, String> votes, List<String> activeOrder) {
    final counts = <String, int>{};
    for (final votedId in votes.values) {
      counts[votedId] = (counts[votedId] ?? 0) + 1;
    }

    final orderIndex = <String, int>{
      for (var i = 0; i < activeOrder.length; i++) activeOrder[i]: i,
    };

    String winner = '';
    int maxVotes = -1;
    int winnerIndex = 1 << 30;

    counts.forEach((playerId, count) {
      final idx = orderIndex[playerId] ?? (1 << 30);
      final isBetter = count > maxVotes || (count == maxVotes && idx < winnerIndex);
      if (isBetter) {
        maxVotes = count;
        winner = playerId;
        winnerIndex = idx;
      }
    });
    return winner;
  }

  // -----------------------------------------------------------------
  // 5) REVEAL FAZI — oylanan oyuncunun kartı açığa çıkar
  // -----------------------------------------------------------------
  RoundState resolveReveal() {
    _assertPhase(RoundPhase.reveal);
    final round = getCurrentRound();
    final eliminatedId = round.eliminatedPlayerId!;
    final eliminated = _getAssignment(round, eliminatedId);

    if (eliminated.cardType == CardType.white) {
      round.phase = RoundPhase.whiteGuess;
      return round;
    }

    if (eliminated.cardType == CardType.main) {
      // Masum yanlışlıkla elendi -> casuslar (kalan hepsi) kazanır, tur biter.
      round.winner = RoundWinner.spies;
      _applyScoring(round);
      round.phase = RoundPhase.result;
      return round;
    }

    // --- CardType.black: KARMA MOD devam kuralı ---
    round.eliminatedPlayerIds.add(eliminatedId);
    round.activeOrder = round.activeOrder.where((id) => id != eliminatedId).toList();

    final remainingHiddenSpies = round.assignments.where((a) =>
        (a.cardType == CardType.black || a.cardType == CardType.white) &&
        !round.eliminatedPlayerIds.contains(a.playerId));

    if (remainingHiddenSpies.isEmpty) {
      // Tüm casuslar bulundu -> Masumlar kazanır, tur biter.
      round.winner = RoundWinner.innocents;
      _applyScoring(round);
      round.phase = RoundPhase.result;
      return round;
    }

    // Güvenlik ağı: anlamlı bir oylama için en az 2 aktif oyuncu gerekir.
    if (round.activeOrder.length <= 1) {
      round.winner = RoundWinner.innocents;
      _applyScoring(round);
      round.phase = RoundPhase.result;
      return round;
    }

    // Hâlâ yakalanmamış casus var -> tur devam eder, yeni döngü.
    round.votes = {};
    round.eliminatedPlayerId = null;
    round.currentTurnIndex = 0;
    round.phase = RoundPhase.discussion;
    return round;
  }

  CardAssignment _getAssignment(RoundState round, String playerId) {
    return round.assignments.firstWhere(
      (a) => a.playerId == playerId,
      orElse: () => throw StateError('Atama bulunamadı: $playerId'),
    );
  }

  // -----------------------------------------------------------------
  // 6) WHITE_GUESS FAZI — özel Beyaz Kart kuralı
  // -----------------------------------------------------------------
  RoundState submitWhiteCardGuess(String playerId, String guessedWord) {
    _assertPhase(RoundPhase.whiteGuess);
    final round = getCurrentRound();

    if (round.eliminatedPlayerId != playerId) {
      throw StateError('Sadece elenen Beyaz Kart sahibi ana kelimeyi tahmin edebilir.');
    }

    final isCorrect = normalizeTr(guessedWord) == normalizeTr(round.wordPair.mainWord);

    round.whiteCardGuess =
        WhiteCardGuess(playerId: playerId, guessedWord: guessedWord, isCorrect: isCorrect);
    // Doğru tahmin: Beyaz Kart TEK BAŞINA kazanır (bu WHITE'a özgü sabit
    // bir kuraldır, gizli kalan başka casus olsa bile tur burada biter).
    // Yanlış tahmin: tüm (sona kadar gizli kalan) casuslar kazanır.
    round.winner = isCorrect ? RoundWinner.whiteCardSolo : RoundWinner.spies;

    _applyScoring(round);
    round.phase = RoundPhase.result;
    return round;
  }

  // -----------------------------------------------------------------
  // 7) PUANLAMA (RESULT fazına geçerken bir kez uygulanır)
  // -----------------------------------------------------------------
  void _applyScoring(RoundState round) {
    switch (round.winner) {
      case RoundWinner.innocents:
        for (final a in round.assignments) {
          if (a.cardType == CardType.main) {
            getPlayer(a.playerId).score += scoreInnocentWin;
          }
        }
        break;
      case RoundWinner.spies:
        // TASARIM NOTU (Karma Mod): Bu turda daha önce yakalanıp elenmiş
        // bir casus (round.eliminatedPlayerIds) artık "bulunmuş" sayılır
        // ve casusların nihai zaferinden puan almaz. Sadece sona kadar
        // TESPİT EDİLEMEDEN kalan casuslar ödüllendirilir.
        for (final a in round.assignments) {
          final isSpy = a.cardType == CardType.black || a.cardType == CardType.white;
          final wasCaughtEarlier = round.eliminatedPlayerIds.contains(a.playerId);
          if (isSpy && !wasCaughtEarlier) {
            getPlayer(a.playerId).score += scoreSpyWin;
          }
        }
        break;
      case RoundWinner.whiteCardSolo:
        final guesserId = round.whiteCardGuess!.playerId;
        getPlayer(guesserId).score += scoreWhiteSoloWin;
        break;
      case null:
        break;
    }
  }

  // -----------------------------------------------------------------
  // 8) TUR SONU
  // -----------------------------------------------------------------
  bool finishRound() {
    _assertPhase(RoundPhase.result);
    return true;
  }

  void endGame() {
    _state.status = GameStatus.finished;
  }
}