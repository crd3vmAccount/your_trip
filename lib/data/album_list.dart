import 'package:your_trip/data/album_utilities.dart';

import 'album.dart';

Future<List<Album>> albumList() async {
  var userAlbumCollection = await getUserAlbumCollection().get();
  var userAlbumDocuments = userAlbumCollection.docs;
  return userAlbumDocuments
      .map((d) => Album(
            d["displayName"],
            sharedWith: _retrieveStringList(d["sharedWith"]),
            photos: _retrieveStringList(d["photos"]),
          ))
      .toList(growable: false);
}

List<String> _retrieveStringList(data) {
  return (data as List<dynamic>).cast();
}
