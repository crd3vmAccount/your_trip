import 'package:your_trip/data/photo.dart';

class Album {
  final String docId;
  final String displayName;
  late final String queryName;
  final List<String> sharedWith;
  final List<Photo> photos;
  final bool isShared;

  Album(
    this.docId,
    this.displayName, {
    this.sharedWith = const [],
    this.photos = const [],
    this.isShared = true,
  }) {
    queryName = displayName.toLowerCase();
  }

  @override
  String toString() {
    return 'Album{displayName: $displayName, queryName: $queryName, sharedWith: $sharedWith, photos: $photos, isShared: $isShared';
  }
}
