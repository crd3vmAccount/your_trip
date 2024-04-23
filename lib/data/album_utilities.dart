import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

CollectionReference<Map<String, dynamic>> getUserAlbumCollection() {
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