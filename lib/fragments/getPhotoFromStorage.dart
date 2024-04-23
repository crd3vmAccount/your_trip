import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:your_trip/data/album_utilities.dart';

Widget getPhotoFromStorage(String photoUrl) {
  requireAuthentication();
  String uid = getUid();
  var bytes = FirebaseStorage.instance.ref("users/$uid/$photoUrl").getData();
  return FutureBuilder(
      future: bytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return const Text("Error! could not retrieve image");
        }
      });
}
