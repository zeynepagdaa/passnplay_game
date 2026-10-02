/// word_pack.dart
/// -----------------------------------------------------------------------
/// Kelime çifti (Ana Kelime + Siyah Kelime) ve paket modeli.
///
/// ÖNEMLİ: WordPack sadece DEPOLAMA/ORGANİZASYON birimidir (dahili paket,
/// kullanıcı paketi vb.). Oyun sırasında wordSelection.buildUnifiedWordPool
/// bu paketleri TEK BİR havuzda birleştirir — paket kimliği seçim
/// aşamasından sonra anlamını yitirir (tek blok kuralı).

class WordPair {
  final String id;
  final String mainWord; // Ana Kart kelimesi (masumlara verilir)
  final String spyWord; // Siyah Kart kelimesi (farklı ama çağrışımlı kelime)
  final String packId; // Bu çiftin geldiği paket (sadece yönetim amaçlı)

  WordPair({
    required this.id,
    required this.mainWord,
    required this.spyWord,
    required this.packId,
  });
}

class WordPack {
  final String id;
  final String name;
  final bool isCustom; // true: kullanıcı paketi, false: dahili kütüphane
  final bool isEditable; // dahili kütüphane düzenlenemez (false)
  final int createdAt;
  final int updatedAt;
  final List<WordPair> pairs;

  WordPack({
    required this.id,
    required this.name,
    required this.isCustom,
    required this.isEditable,
    required this.createdAt,
    required this.updatedAt,
    required this.pairs,
  });
}

const String defaultPackId = 'default_builtin_pack';

int _pairCounter = 0;

String _generatePairId() {
  _pairCounter += 1;
  final rand = (DateTime.now().microsecondsSinceEpoch % 1000000)
      .toRadixString(36);
  final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  return 'pair_${ts}_${_pairCounter}_$rand';
}

/// Türkçe büyük/küçük harf dönüşümünde 'İ/i' ve 'I/ı' ayrımı standart
/// toLowerCase() ile doğru çalışmaz (dotless/dotted I sorunu). Kelime
/// eşitlik kontrolleri için basit bir Türkçe normalizasyonu uygulanır.
String normalizeTr(String word) {
  var w = word.trim();
  w = w.replaceAll('İ', 'i').replaceAll('I', 'ı');
  w = w.toLowerCase();
  return w;
}

/// Yeni bir WordPair oluşturur. mainWord ve spyWord aynı olamaz
/// (aksi halde casus ile masum arasında fark kalmaz).
WordPair createWordPair(String mainWord, String spyWord, String packId) {
  final main = mainWord.trim();
  final spy = spyWord.trim();
  if (main.isEmpty || spy.isEmpty) {
    throw ArgumentError('Ana kelime ve siyah kelime boş olamaz.');
  }
  if (normalizeTr(main) == normalizeTr(spy)) {
    throw ArgumentError(
        'Ana kelime ile siyah kelime aynı olamaz ("$main"). Casus kartı '
        'ancak farklı bir kelimeyle anlamlıdır.');
  }
  return WordPair(id: _generatePairId(), mainWord: main, spyWord: spy, packId: packId);
}

/// Yeni (boş) bir kullanıcı paketi oluşturur.
WordPack createUserWordPack(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Paket adı boş olamaz.');
  }
  final now = DateTime.now().millisecondsSinceEpoch;
  final rand = (now % 100000).toRadixString(36);
  return WordPack(
    id: 'pack_${now.toRadixString(36)}_$rand',
    name: trimmed,
    isCustom: true,
    isEditable: true,
    createdAt: now,
    updatedAt: now,
    pairs: [],
  );
}