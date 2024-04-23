class Album {
  final String displayName;
  late final String queryName;
  final List<String>? sharedWith;
  final List<String>? photos;

  Album(this.displayName, {this.sharedWith, this.photos}) {
    queryName = displayName.toLowerCase();
  }
}
