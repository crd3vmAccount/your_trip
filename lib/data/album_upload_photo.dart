import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:your_trip/data/album.dart';
import 'package:your_trip/data/album_utilities.dart';

Future<void> albumUploadPhoto() async {
  requireAuthentication();
  var userAlbumCollection = getUserAlbumCollection();
  var storage = FirebaseStorage.instance;
  var uid = getUid();
  var uuid = const Uuid().v8();
  storage.ref().child("users/$uid/$uuid").putString("data");
}