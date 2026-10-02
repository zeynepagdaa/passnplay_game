// Çalıştırmak için: flutter test
//
// Bu dosya, TypeScript prototipinde (test/simulate.ts, test/tiebreak.test.ts,
// test/mixedModeContinuation.test.ts, test/multiBlackAllCaught.test.ts)
// ts-node ile GERÇEKTEN ÇALIŞTIRILARAK doğrulanmış senaryoların birebir
// Dart karşılığıdır. Bu sandbox'ta Flutter/Dart SDK bulunmadığı için bu
// dosya burada çalıştırılamadı — lütfen kendi ortamında `flutter test`
// ile doğrula.

import 'package:flutter_test/flutter_test.dart';

import 'package:casus_oyunu/models/player.dart';
import 'package:casus_oyunu/models/word_pack.dart';
import 'package:casus_oyunu/models/card_assignment.dart';
import 'package:casus_oyunu/models/game_state.dart';
import 'package:casus_oyunu/engine/game_engine.dart';
import 'package:casus_oyunu/engine/spy_distribution.dart';
import 'package:casus_oyunu/engine/word_selection.dart';

WordPack _testPack(List<List<String>> rows) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return WordPack(
    id: defaultPackId,
    name: 'Test',
    isCustom: false,
    isEditable: false,
    createdAt: now,
    updatedAt: now,
    pairs: [
      for (final r in rows) createWordPair(r[0], r[1], defaultPackId),
    ],
  );
}

void main() {
  group('%30 Casus Sınırı', () {
    test('n=3..20 arası cap hiçbir zaman aşılmaz, n<6 için her zaman 1 casus', () {
      for (var n = 3; n <= 20; n++) {
        final effectiveMax = ((n * 0.3).floor()).clamp(1, n);
        for (var trial = 0; trial < 300; trial++) {
          final dist = calculateSpyDistribution(n, preference: SpyModePreference.random);
          expect(dist.total, lessThanOrEqualTo(effectiveMax),
              reason: 'n=$n icin total=${dist.total} > izinliMax=$effectiveMax');
          if (n < 6) {
            expect(dist.total, equals(1));
          }
        }
      }
    });

    test('n=7 MIXED en az bir kez hem BLACK hem WHITE üretir, cap aşılmaz', () {
      var sawMixed = false;
      for (var i = 0; i < 200; i++) {
        final d = calculateSpyDistribution(7, preference: SpyModePreference.mixed);
        if (d.blackCount > 0 && d.whiteCount > 0) sawMixed = true;
        expect(d.total, lessThanOrEqualTo(getMaxSpyCount(7)));
      }
      expect(sawMixed, isTrue);
    });
  });

  test('Uçtan uca round akışı: DEALING -> ... -> RESULT (5 oyuncu, 1 casus)', () {
    final players = [
      createPlayer('Ayşe'),
      createPlayer('Mehmet'),
      createPlayer('Zeynep'),
      createPlayer('Ali'),
      createPlayer('Fatma'),
    ];
    final pack = _testPack([
      ['Kahve', 'Çay'],
      ['Deniz', 'Göl'],
    ]);
    final pool = buildUnifiedWordPool([pack], [defaultPackId]);
    final engine = GameEngine(
      players,
      GameSettings(playerCount: players.length, selectedPackIds: [defaultPackId]),
      pool,
    );

    final round = engine.startNewRound(spyPreference: SpyModePreference.random);
    expect(round.phase, RoundPhase.dealing);
    expect(round.spyCount.black + round.spyCount.white, 1);

    // MAIN/BLACK'in hepsinde word dolu, WHITE'ta null
    final mainOrBlack = round.assignments.where((a) => a.cardType != CardType.white);
    expect(mainOrBlack.every((a) => (a.word ?? '').isNotEmpty), isTrue);
    final whites = round.assignments.where((a) => a.cardType == CardType.white);
    expect(whites.every((a) => a.word == null), isTrue);

    for (final pid in round.turnOrder) {
      expect(engine.getPlayerAwaitingCardView(), pid);
      engine.confirmCardViewed(pid);
    }
    expect(round.phase, RoundPhase.discussion);

    for (var i = 0; i < round.activeOrder.length; i++) {
      engine.advanceDiscussionTurn();
    }
    expect(round.phase, RoundPhase.voting);

    final spyAssignment = round.assignments.firstWhere((a) => a.cardType != CardType.main);
    for (final voterId in round.activeOrder) {
      engine.submitVote(voterId, spyAssignment.playerId);
    }
    expect(round.eliminatedPlayerId, spyAssignment.playerId);

    if (round.phase == RoundPhase.reveal) {
      engine.resolveReveal();
    }

    if (spyAssignment.cardType == CardType.white) {
      expect(round.phase, RoundPhase.whiteGuess);
      engine.submitWhiteCardGuess(spyAssignment.playerId, 'yanlis-kelime-xyz');
      expect(round.winner, RoundWinner.spies);
    } else {
      expect(round.phase, RoundPhase.result);
      expect(round.winner, RoundWinner.innocents);
      final innocent = players.firstWhere((p) => p.id != spyAssignment.playerId);
      expect(innocent.score, scoreInnocentWin);
    }
  });

  test('Oylama eşitliği (tie-break) activeOrder sırasına göre çözülür', () {
    final players = [createPlayer('A'), createPlayer('B'), createPlayer('C'), createPlayer('D')];
    final pack = _testPack([
      ['Kahve', 'Çay'],
    ]);
    final pool = buildUnifiedWordPool([pack], [defaultPackId]);
    final engine = GameEngine(
      players,
      GameSettings(playerCount: 4, allowMixedMode: false, selectedPackIds: [defaultPackId]),
      pool,
    );

    final round = engine.startNewRound(spyPreference: SpyModePreference.blackOnly);
    for (final pid in round.turnOrder) {
      engine.confirmCardViewed(pid);
    }
    for (var i = 0; i < round.activeOrder.length; i++) {
      engine.advanceDiscussionTurn();
    }

    final p0 = round.turnOrder[0];
    final p1 = round.turnOrder[1];
    final p2 = round.turnOrder[2];
    final p3 = round.turnOrder[3];

    engine.submitVote(p0, p0);
    engine.submitVote(p1, p0);
    engine.submitVote(p2, p1);
    engine.submitVote(p3, p1);

    expect(round.eliminatedPlayerId, p0,
        reason: "2-2 eşitliğinde activeOrder'da önce gelen ($p0) elenmeli");
  });

  test('Karma Mod: biri yakalanınca tur bitmez, ikisi de yakalanınca biter', () {
    final players = List.generate(10, (i) => createPlayer('P${i + 1}'));
    final pack = _testPack([
      ['Kahve', 'Çay'],
    ]);
    final pool = buildUnifiedWordPool([pack], [defaultPackId]);

    late GameEngine engine;
    late RoundState round;
    String blackId = '';
    String whiteId = '';
    do {
      engine = GameEngine(
        players,
        GameSettings(playerCount: 10, selectedPackIds: [defaultPackId]),
        pool,
      );
      round = engine.startNewRound(spyPreference: SpyModePreference.mixed);
      final blacks = round.assignments.where((a) => a.cardType == CardType.black).toList();
      final whitesList = round.assignments.where((a) => a.cardType == CardType.white).toList();
      if (blacks.isNotEmpty && whitesList.isNotEmpty) {
        blackId = blacks.first.playerId;
        whiteId = whitesList.first.playerId;
      }
    } while (blackId.isEmpty || whiteId.isEmpty);

    for (final pid in round.turnOrder) {
      engine.confirmCardViewed(pid);
    }
    for (var i = 0; i < round.activeOrder.length; i++) {
      engine.advanceDiscussionTurn();
    }

    // BLACK'i yakala
    final decoy1 = players.firstWhere((p) => p.id != blackId).id;
    for (final voterId in round.activeOrder) {
      engine.submitVote(voterId, voterId == blackId ? decoy1 : blackId);
    }
    engine.resolveReveal();

    expect(round.phase, RoundPhase.discussion,
        reason: 'BLACK yakalandı ama WHITE hâlâ gizli -> tur devam etmeli');
    expect(round.winner, isNull);
    expect(round.activeOrder.contains(blackId), isFalse);
    expect(round.activeOrder.length, 9);

    for (var i = 0; i < round.activeOrder.length; i++) {
      engine.advanceDiscussionTurn();
    }

    // Şimdi WHITE'ı yakala
    final decoy2 = round.activeOrder.firstWhere((id) => id != whiteId);
    for (final voterId in round.activeOrder) {
      engine.submitVote(voterId, voterId == whiteId ? decoy2 : whiteId);
    }
    engine.resolveReveal();
    expect(round.phase, RoundPhase.whiteGuess);

    engine.submitWhiteCardGuess(whiteId, 'yanlis-kelime');
    expect(round.winner, RoundWinner.spies);

    final blackPlayer = players.firstWhere((p) => p.id == blackId);
    final whitePlayer = players.firstWhere((p) => p.id == whiteId);
    expect(blackPlayer.score, 0,
        reason: 'Erken yakalanan BLACK, SPIES zaferinden puan almamalı');
    expect(whitePlayer.score, scoreSpyWin,
        reason: 'Sona kadar gizli kalan WHITE, SPIES zaferinden puan almalı');
  });
}