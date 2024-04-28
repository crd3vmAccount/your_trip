import 'package:latlong2/latlong.dart';

class Photo {
  String photoUrl;
  LatLng location;
  Photo(this.photoUrl, this.location);

  @override
  String toString() {
    return 'Photo{photoUrl: $photoUrl, location: $location}';
  }
}