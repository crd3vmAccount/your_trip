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

  Future<Album> staticAlbumGet(String albumName) async {
    return (await _getUserAlbumCollection()
            .where("queryName", isEqualTo: albumName.toLowerCase())
            .limit(1)
            .get())
        .docs
        .map((d) => _queryToAlbum(d))
        .single;
  }

  Stream<Album> liveAlbumGet(String albumName) {
    return _getUserAlbumCollection()
        .where("queryName", isEqualTo: albumName.toLowerCase())
        .limit(1)
        .snapshots()
        .expand((snapshot) => snapshot.docs)
        .map((albumData) => _queryToAlbum(albumData));
  }

  Future<List<Album>> staticAlbumList() async {
    return (await _getUserAlbumCollection().get())
        .docs
        .map((d) => _queryToAlbum(d))
        .toList();
  }

  Stream<List<Album>> liveAlbumList() {
    return _getUserAlbumCollection()
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

  Future<List<Uint8List>> staticPhotoList(Album album) async {
    return album.photos
        .map((p) => photo2Bytes(p))
        .where((element) => element != null)
        .toList(growable: false)
        .cast<Uint8List>();
  }

  Future<bool> renameAlbum(Album album, String newName) async {
    if (await isNotDuplicate(newName)) {
      await _getUserAlbumCollection().doc(album.docId).update({
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
      await _getUserAlbumCollection().doc(uniqueId).set({
        "displayName": albumName,
        "queryName": albumName.toLowerCase(),
        "sharedWith": [],
        "photos": [],
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
    var matches = await _getUserAlbumCollection()
        .where("queryName", isEqualTo: albumName.toLowerCase())
        .limit(1)
        .get();
    return matches.docs.isEmpty;
  }

  Future<void> shareWith(Album album, String email) async {
    _getUserAlbumCollection().doc(album.docId).update({
      "sharedWith": FieldValue.arrayUnion([email])
    });
  }

  Future<void> unshareWith(Album album, String email) async {
    _getUserAlbumCollection().doc(album.docId).update({
      "sharedWith": FieldValue.arrayRemove([email])
    });
  }

  Stream<List<String>> liveSharedWith(Album album) {
    return _getUserAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrieveStringList(snapshot.data()?["sharedWith"]));
  }

  Stream<List<Photo>> livePhotos(Album album) {
    return _getUserAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrievePhotoList(snapshot.data()?["photos"]));
  }

  Stream<List<Future<Uint8List?>>> livePhotoBytes(Album album) {
    return _getUserAlbumCollection()
        .doc(album.docId)
        .snapshots()
        .map((snapshot) => _retrievePhotoList(snapshot.data()?["photos"]))
        .map((photoList) => photoList.map((photo) => photo.photoUrl))
        .map((urls) => urls
            .map((e) => FirebaseStorage.instance.ref(e).getData())
            .toList());
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
          await _getUserAlbumCollection().doc(album.docId).update({
            "photos": FieldValue.arrayUnion([
              {
                "photoUrl": "$folder/$file",
                "location": {
                  "latitude": coordinates.latitude,
                  "longitude": coordinates.longitude,
                },
              }
            ])
          })
        });
  }

  Album _queryToAlbum(QueryDocumentSnapshot<Map<String, dynamic>> data) {
    return Album(
      data.id,
      data["displayName"],
      sharedWith: _retrieveStringList(data["sharedWith"]),
      photos: _retrievePhotoList(data["photos"]),
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

  CollectionReference<Map<String, dynamic>> _getUserAlbumCollection() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid())
        .collection("albums");
  }
}
