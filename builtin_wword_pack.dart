import '../models/word_pack.dart';
import 'builtin_word_pairs.dart';

/// [builtinWordPairsRaw] ham verisinden çalıştırma zamanında bir
/// [WordPack] (dahili, düzenlenemez) üretir.
WordPack buildBuiltinWordPack() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final pairs = <WordPair>[];
  for (var i = 0; i < builtinWordPairsSource.length; i++) {
    final row = builtinWordPairsSource[i];
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