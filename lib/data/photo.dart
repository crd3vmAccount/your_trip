import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

class Photo {
  String photoUrl;
  LatLng location;
  Uint8List? bytes;

  Photo(this.photoUrl, this.location, {this.bytes});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo &&
          runtimeType == other.runtimeType &&
          photoUrl == other.photoUrl &&
          location == other.location;

  @override
  int get hashCode => photoUrl.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'Photo{photoUrl: $photoUrl, location: $location}';
  }
}
