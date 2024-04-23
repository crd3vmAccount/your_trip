import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'album_utilities.dart';
import 'album.dart';

Future<void> albumCreate(Album album) async {
  var userAlbums = getUserAlbumCollection();
  if (await _isNotDuplicate(userAlbums, album)) {
    _createAlbum(userAlbums, album);
  } else {
    throw ArgumentError("Album name is not unique");
  }
}

Future<void> _createAlbum(
  CollectionReference userAlbums,
  Album album,
) async {
  var newAlbum = userAlbums.doc(album.displayName);
  newAlbum.set({
    "displayName": album.displayName,
    "queryName": album.queryName,
    "sharedWith": album.sharedWith ?? [],
    "photos": album.photos ?? [],
  });
}

Future<bool> _isNotDuplicate(
  CollectionReference userAlbums,
  Album album,
) async {
  var matches = await userAlbums
      .where("queryName", isEqualTo: album.displayName.toLowerCase())
      .limit(1)
      .get();
  return matches.docs.isEmpty;
}
