enum SearchContentType {
  quran,
  adhkar,
  hadith,
  general,
}

class SearchItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? content;
  final String? reference;
  final SearchContentType type;
  final int? surahNumber;
  final int? ayahNumber;
  final int? pageNumber;

  const SearchItem({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
    this.content,
    this.reference,
    this.surahNumber,
    this.ayahNumber,
    this.pageNumber,
  });

  String get searchableText => [
    title,
    subtitle ?? '',
    content ?? '',
    reference ?? '',
  ].join(' ');
}
