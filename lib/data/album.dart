class Album {
  final String docId;
  final String displayName;
  late final String queryName;
  final List<String> sharedWith;
  final List<String> photos;

  Album(
    this.docId,
    this.displayName, {
    this.sharedWith = const [],
    this.photos = const [],
  }) {
    queryName = displayName.toLowerCase();
  }

  @override
  String toString() {
    return 'Album{displayName: $displayName, queryName: $queryName, sharedWith: $sharedWith, photos: $photos}';
  }
}
