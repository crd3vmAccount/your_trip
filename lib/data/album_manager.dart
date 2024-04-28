import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:your_trip/data/location_manager.dart';
import 'package:your_trip/data/photo.dart';

import 'album.dart';

class AlbumManager {
  AlbumManager._();

  static final AlbumManager _instance = AlbumManager._();

  static AlbumManager get instance {
    return _instance;
  }

  Future<Album> staticGet(String albumName) async {
    return (await _getUserAlbumCollection()
            .where("queryName", isEqualTo: albumName.toLowerCase())
            .limit(1)
            .get())
        .docs
        .map((d) => _queryToAlbum(d))
        .single;
  }

  Stream<Album> liveGet(String albumName) {
    return _getUserAlbumCollection()
        .where("queryName", isEqualTo: albumName.toLowerCase())
        .limit(1)
        .snapshots()
        .expand((snapshot) => snapshot.docs)
        .map((albumData) => _queryToAlbum(albumData));
  }

  Future<List<Album>> staticList() async {
    return (await _getUserAlbumCollection().get())
        .docs
        .map((d) => _queryToAlbum(d))
        .toList();
  }

  Stream<List<Album>> liveList() {
    return _getUserAlbumCollection()
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => _queryToAlbum(d)).toList());
  }

  Future<Uint8List?> staticRandomPhoto(Album album) async {
    var photo = album.photos[Random().nextInt(album.photos.length)];
    print(photo);
    return await FirebaseStorage.instance.ref(photo.photoUrl).getData();
  }

  Future<List<Uint8List>> staticPhotoList(Album album) async {
    List<Uint8List> futures = [];
    for (String url in album.photos.map((p) => p.photoUrl)) {
      var reference = FirebaseStorage.instance.ref(url);
      var data = await reference.getData();
      if (data != null) {
        futures.add(data);
      }
    }
    return futures;
  }

  Future<bool> create(String albumName) async {
    if (await isNotDuplicate(albumName)) {
      await _getUserAlbumCollection().doc(albumName).set({
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

  Stream<List<Future<Uint8List?>>> livePhotos(Album album) {
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
