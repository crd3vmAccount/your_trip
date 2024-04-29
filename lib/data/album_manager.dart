import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v8.dart';
import 'package:your_trip/data/location_manager.dart';
import 'package:your_trip/data/photo.dart';

import 'album.dart';

class AlbumManager {
  AlbumManager._();

  static final AlbumManager _instance = AlbumManager._();

  static AlbumManager get instance {
    return _instance;
  }

  Stream<List<Album>> liveSharedAlbumList() {
    return _getAlbumCollection()
        .where(
          "sharedWith",
          arrayContains: FirebaseAuth.instance.currentUser!.email,
        )
        .orderBy("lastEdited", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => _queryToAlbum(d, isShared: true))
            .toList());
  }

  Stream<List<Album>> liveAlbumList() {
    return _getAlbumCollection()
        .where("creator", isEqualTo: uid())
        .orderBy("lastEdited", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => _queryToAlbum(d)).toList());
  }

  Future<Uint8List?> staticRandomPhotoBytes(Album album) async {
    var photo = album.photos[Random().nextInt(album.photos.length)];
    return photo2Bytes(photo);
  }

  Future<Uint8List?> photo2Bytes(Photo photo) async {
    return await FirebaseStorage.instance.ref(photo.photoUrl).getData();
  }

  Future<void> deleteAlbum(Album album) async {
    album.photos.map((photo) => photo.photoUrl).forEach((photoUrl) {
      FirebaseStorage.instance.ref(photoUrl).delete();
    });
    await _getAlbumCollection().doc(album.docId).delete();
  }

  Future<void> deletePhoto(Album album, Photo photo) async {
    FirebaseStorage.instance.ref(photo.photoUrl).delete();
    _getAlbumCollection().doc(album.docId).update({
      "photos": FieldValue.arrayRemove([
        {
          "location": {
            "latitude": photo.location.latitude,
            "longitude": photo.location.longitude,
          },
          "photoUrl": photo.photoUrl,
        }
      ]),
      "lastEdited": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> renameAlbum(Album album, String newName) async {
    if (await isNotDuplicate(newName)) {
      await _getAlbumCollection().doc(album.docId).update({
        "displayName": newName,
        "queryName": newName.toLowerCase(),
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createAlbum(String albumName) async {
    if (await isNotDuplicate(albumName)) {
      var uniqueId = const Uuid().v8();
      await _getAlbumCollection().doc(uniqueId).set({
        "creator": uid(),
        "displayName": albumName,
        "queryName": albumName.toLowerCase(),
        "sharedWith": [],
        "photos": [],
        "lastEdited": FieldValue.serverTimestamp(),
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isDuplicate(String albumName) async {
    return !await isNotDuplicate(albumName);
  }

  Future<bool> isNotDuplicate(String albumName) async {
    var matches = await _getAlbumCollection()
        .where("queryName", isEqualTo: albumName.toLowerCase())
        .limit(1)
        .get();
    return matches.docs.isEmpty;
  }

  Future<void> shareWith(Album album, String email) async {
    _getAlbumCollection().doc(album.docId).update({
      "sharedWith": FieldValue.arrayUnion([email])
    });
  }

  Future<void> unshareWith(Album album, String email) async {
    _getAlbumCollection().doc(album.docId).update({
      "sharedWith": FieldValue.arrayRemove([email])
    });
  }

  Stream<List<String>> liveSharedWith(Album album) {
    return _getAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrieveStringList(snapshot.data()?["sharedWith"]));
  }

  Stream<List<Photo>> livePhotos(Album album) {
    return _getAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrievePhotoList(snapshot.data()?["photos"]));
  }

  Stream<List<Future<Photo>>> livePhotoWithBytes(Album album) {
    return _getAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrievePhotoList(snapshot.data()?["photos"]))
        .map((photos) => photos.map((photo) async {
              photo.bytes =
                  await FirebaseStorage.instance.ref(photo.photoUrl).getData();
              return photo;
            }).toList());
  }

  String uid() {
    if (FirebaseAuth.instance.currentUser == null) {
      throw ArgumentError("User must be authenticated");
    }
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> uploadImage(Album album, XFile image) async {
    var coordinates = await LocationManager.currentPositionOrDefault();
    var folder = "users/${uid()}";
    var file = const Uuid().v8();
    var bytes = await image.readAsBytes();
    var reference = FirebaseStorage.instance.ref(folder).child(file);
    var uploadTask = reference.putData(bytes);
    await uploadTask.whenComplete(() async => {
          await _getAlbumCollection().doc(album.docId).update({
            "photos": FieldValue.arrayUnion([
              {
                "photoUrl": "$folder/$file",
                "location": {
                  "latitude": coordinates.latitude,
                  "longitude": coordinates.longitude,
                },
              }
            ]),
            "lastEdited": FieldValue.serverTimestamp(),
          })
        });
  }

  Album _queryToAlbum(
    QueryDocumentSnapshot<Map<String, dynamic>> data, {
    isShared = false,
  }) {
    return Album(
      data.id,
      data["displayName"],
      sharedWith: _retrieveStringList(data["sharedWith"]),
      photos: _retrievePhotoList(data["photos"]),
      isShared: isShared,
    );
  }

  Photo _retrievePhoto(dynamic data) {
    var photoUrl = data["photoUrl"] as String;
    var locData = data["location"] as Map<String, dynamic>;
    var location = LatLng(
      locData["latitude"]! as double,
      locData["longitude"]! as double,
    );
    return Photo(photoUrl, location);
  }

  List<Photo> _retrievePhotoList(List<dynamic> data) {
    return data
        .map((photoData) => _retrievePhoto(photoData))
        .toList(growable: false);
  }

  List<String> _retrieveStringList(data) {
    return (data as List<dynamic>).cast();
  }

  CollectionReference<Map<String, dynamic>> _getAlbumCollection() {
    return FirebaseFirestore.instance.collection("albums");
  }
}
