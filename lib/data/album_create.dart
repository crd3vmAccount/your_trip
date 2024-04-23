import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'album.dart';

void albumCreate(Album album) async {
  var userAlbums = _getUserAlbumCollection();
  if (await _isNotDuplicate(userAlbums, album)) {
    _createAlbum(userAlbums, album);
  } else {
    throw ArgumentError("Album name is not unique");
  }
}

CollectionReference<Map<String, dynamic>> _getUserAlbumCollection() {
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw ArgumentError("Account is not authenticated");
  } else {
    var fireStore = FirebaseFirestore.instance;
    var users = fireStore.collection("users");
    var userContent = users.doc(user.uid);
    var userAlbums = userContent.collection("albums");
    return userAlbums;
  }
}

void _createAlbum(
  CollectionReference userAlbums,
  Album album,
) {
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
  print("Duplicate? ${matches.docs.isNotEmpty}");
  return matches.docs.isEmpty;
}
