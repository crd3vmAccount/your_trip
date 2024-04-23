import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void requireAuthentication() {
  if (FirebaseAuth.instance.currentUser == null) {
    throw ArgumentError("Account is not authenticated");
  }
}

String getUid() {
  requireAuthentication();
  var user = FirebaseAuth.instance.currentUser;
  return user!.uid;
}

CollectionReference<Map<String, dynamic>> getUserAlbumCollection() {
  var user = FirebaseAuth.instance.currentUser;
  var fireStore = FirebaseFirestore.instance;
  var users = fireStore.collection("users");
  var userContent = users.doc(user!.uid);
  var userAlbums = userContent.collection("albums");
  return userAlbums;
}
