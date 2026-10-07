import '../models/word_pack.dart';
import 'builtin_word_pairs.dart';

const String defaultPackId = 'builtin_default_pack';

/// [builtinWordPairsRaw] verisinden dahili WordPack üretir.
WordPack buildBuiltinWordPack() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final pairs = <WordPair>[];

  // builtin_word_pairs.dart içindeki listenin adı builtinWordPairsRaw olduğu için doğrudan onu kullanıyoruz
  for (var i = 0; i < builtinWordPairsRaw.length; i++) {
    final row = builtinWordPairsRaw[i];
    pairs.add(WordPair(
      id: 'builtin_$i',
      mainWord: row[0],
      spyWord: row[1],
      packId: defaultPackId,
    ));
  }

  return WordPack(
    id: defaultPackId,
    name: 'Dahili Kütüphane',
    isCustom: false,
    isEditable: false,
    createdAt: now,
    updatedAt: now,
    pairs: pairs,
  );
}