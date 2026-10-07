

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/word_pack.dart';
import '../models/game_state.dart';
import '../engine/game_engine.dart';
import '../engine/spy_distribution.dart';
import '../engine/word_selection.dart';
import '../engine/builtin_word_pack.dart';

const String _customPacksPrefsKey = 'custom_word_packs_v1';

class GameProvider extends ChangeNotifier {
  final List<Player> _players = [];
  final List<WordPack> _customPacks = [];
  late final WordPack _builtinPack;
  final Set<String> _selectedPackIds = {};

  GameEngine? _engine;
  GameSettings? _settings;
  SharedPreferences? _prefs;

  GameProvider() {
    _builtinPack = buildBuiltinWordPack();
    _selectedPackIds.add(_builtinPack.id);
    _loadCustomPacksFromDisk();
  }

  void resolveVotingResult() {
    if (_engine == null) return;
    _engine!.resolveVotingResult();
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Oyuncu Yönetimi (Kurulum ekranı)
  // ---------------------------------------------------------------
  List<Player> get players => List.unmodifiable(_players);

  String? addPlayer(String name) {
    try {
      final player = createPlayer(name);
      _players.add(player);
      notifyListeners();
      return null; // hata yok
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  void removePlayer(String playerId) {
    _players.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Kelime Paketi Yönetimi
  // ---------------------------------------------------------------
  WordPack get builtinPack => _builtinPack;
  List<WordPack> get customPacks => List.unmodifiable(_customPacks);
  List<WordPack> get allPacks => [_builtinPack, ..._customPacks];
  Set<String> get selectedPackIds => Set.unmodifiable(_selectedPackIds);

  void togglePackSelected(String packId, bool selected) {
    if (selected) {
      _selectedPackIds.add(packId);
    } else {
      _selectedPackIds.remove(packId);
    }
    notifyListeners();
  }

  String? createCustomPack(String name) {
    try {
      final pack = createUserWordPack(name);
      _customPacks.add(pack);
      _selectedPackIds.add(pack.id);
      _persistCustomPacks();
      notifyListeners();
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? addWordPairToPack(String packId, String mainWord, String spyWord) {
    final packIndex = _customPacks.indexWhere((p) => p.id == packId);
    if (packIndex == -1) return 'Paket bulunamadı (dahili kütüphane düzenlenemez).';
    try {
      final pair = createWordPair(mainWord, spyWord, packId);
      _customPacks[packIndex].pairs.add(pair);
      _persistCustomPacks();
      notifyListeners();
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  void removeWordPairFromPack(String packId, String pairId) {
    final pack = _customPacks.firstWhere((p) => p.id == packId, orElse: () => _builtinPack);
    if (!pack.isEditable) return;
    pack.pairs.removeWhere((p) => p.id == pairId);
    _persistCustomPacks();
    notifyListeners();
  }

  void deleteCustomPack(String packId) {
    _customPacks.removeWhere((p) => p.id == packId);
    _selectedPackIds.remove(packId);
    _persistCustomPacks();
    notifyListeners();
  }

  Future<void> _loadCustomPacksFromDisk() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_customPacksPrefsKey);
    if (raw == null) return;
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _customPacks.clear();
      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final pairs = (map['pairs'] as List<dynamic>).map((p) {
          final pm = p as Map<String, dynamic>;
          return WordPair(
            id: pm['id'] as String,
            mainWord: pm['mainWord'] as String,
            spyWord: pm['spyWord'] as String,
            packId: pm['packId'] as String,
          );
        }).toList();
        _customPacks.add(WordPack(
          id: map['id'] as String,
          name: map['name'] as String,
          isCustom: true,
          isEditable: true,
          createdAt: map['createdAt'] as int,
          updatedAt: map['updatedAt'] as int,
          pairs: pairs,
        ));
        _selectedPackIds.add(map['id'] as String);
      }
      notifyListeners();
    } catch (_) {
      // Bozuk/geçersiz veri varsa sessizce yok say — oyun dahili kütüphane
      // ile çalışmaya devam edebilir.
    }
  }

  Future<void> _persistCustomPacks() async {
    _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(_customPacks
        .map((pack) => {
              'id': pack.id,
              'name': pack.name,
              'createdAt': pack.createdAt,
              'updatedAt': pack.updatedAt,
              'pairs': pack.pairs
                  .map((p) => {
                        'id': p.id,
                        'mainWord': p.mainWord,
                        'spyWord': p.spyWord,
                        'packId': p.packId,
                      })
                  .toList(),
            })
        .toList());
    await _prefs!.setString(_customPacksPrefsKey, encoded);
  }

  // ---------------------------------------------------------------
  // Oyun Motoru (GameEngine) Köprüsü
  // ---------------------------------------------------------------
  GameEngine? get engine => _engine;
  RoundState? get currentRound {
    final e = _engine;
    if (e == null) return null;
    try {
      return e.getCurrentRound();
    } catch (_) {
      return null;
    }
  }

  /// %30 casus tavanına göre bu oyuncu sayısı için maksimum casus sayısı.
  int maxSpyCountForCurrentPlayers() {
    if (_players.length < minPlayers) return 0;
    return getMaxSpyCount(_players.length);
  }

  String? startGame() {
    if (_players.length < minPlayers) {
      return 'Oyun en az $minPlayers oyuncu gerektirir.';
    }
    if (_selectedPackIds.isEmpty) {
      return 'En az bir kelime paketi seçmelisiniz.';
    }
    _settings = GameSettings(
      playerCount: _players.length,
      selectedPackIds: _selectedPackIds.toList(),
    );
    _engine = GameEngine(_players, _settings!, _buildPool());
    notifyListeners();
    return null;
  }

  List<WordPair> _buildPool() {
    return buildUnifiedWordPool(allPacks, _selectedPackIds.toList());
  }

  RoundState startNewRound({SpyModePreference preference = SpyModePreference.random}) {
    final round = _engine!.startNewRound(spyPreference: preference);
    notifyListeners();
    return round;
  }

  void confirmCardViewed(String playerId) {
    _engine!.confirmCardViewed(playerId);
    notifyListeners();
  }

  void advanceDiscussionTurn() {
    _engine!.advanceDiscussionTurn();
    notifyListeners();
  }

  void submitVote(String voterId, String votedPlayerId) {
    _engine!.submitVote(voterId, votedPlayerId);
    notifyListeners();
  }

  void resolveReveal() {
    _engine!.resolveReveal();
    notifyListeners();
  }

  void submitWhiteCardGuess(String playerId, String guessedWord) {
    _engine!.submitWhiteCardGuess(playerId, guessedWord);
    notifyListeners();
  }

  void finishRound() {
    _engine!.finishRound();
    notifyListeners();
  }

  /// Skor tablosu için oyuncuları puana göre azalan sırada döner.
  List<Player> playersByScoreDesc() {
    final sorted = List<Player>.from(_players);
    sorted.sort((a, b) => b.score - a.score);
    return sorted;
  }

  void resetGame() {
    _engine = null;
    _settings = null;
    for (final p in _players) {
      p.score = 0;
    }
    notifyListeners();
  }
}