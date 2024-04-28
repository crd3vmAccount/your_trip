import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationManager {
  LocationManager._();

  static Future<LatLng> currentPositionOrDefault({LatLng defaultLocation = const LatLng(50.5, 30.51)}) async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      return defaultLocation;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return defaultLocation;
      }
    } else if (permission == LocationPermission.deniedForever) {
      return defaultLocation;
    }
    var position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}