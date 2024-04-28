import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../data/album.dart';
import '../../data/album_manager.dart';
import '../../data/location_manager.dart';
import '../../data/photo.dart';

class AlbumMapView extends StatelessWidget {
  final Album album;

  const AlbumMapView({required this.album, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album Title"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      body: AlbumMapWidget(album: album),
    );
  }

  Future<void> takePicture() async {
    final ImagePicker imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await AlbumManager.instance.uploadImage(album, image);
    }
  }
}



class AlbumMapWidget extends StatefulWidget {
  final Album album;

  const AlbumMapWidget({required this.album, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AlbumMapState();
  }
}

class _AlbumMapState extends State<AlbumMapWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocationManager.currentPositionOrDefault(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return FlutterMap(
              options: MapOptions(initialCenter: snapshot.data!),
              children: [
                _buildTileLayer(),
                _buildCurrentLocationLayer(),
                _buildStopMarkerLayer(),
              ],
            );
          }
        });
  }

  Widget _buildStopMarkerLayer() {
    return StreamBuilder(
      stream: AlbumManager.instance.livePhotos(widget.album),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MarkerLayer(
              markers: snapshot.data!.map((p) => Marker(
                point: p.location,
                width: 350,
                child: const _PhotoMarker(),
              )).toList(growable: false)
          );
        } else {
          return MarkerLayer(
            markers: widget.album.photos
                .map((photo) => Marker(
              point: photo.location,
              width: 350,
              child: const _PhotoMarker(),
            ))
                .toList(growable: false),
          );
        }
      },
    );
  }

  Widget _buildCurrentLocationLayer() {
    return FutureBuilder(
        future: _getCurrentLocationOrError(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return snapshot.data!;
            }
          }
          return const Text("");
        });
  }

  Future<Widget> _getCurrentLocationOrError() async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location services were denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location services were denied permanently.');
    }
    return Future.value(CurrentLocationLayer());
  }

  TileLayer _buildTileLayer() => TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        userAgentPackageName: "dev.flutter",
      );
}

class _PhotoMarker extends StatelessWidget {
  const _PhotoMarker();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_pin,
      size: 50,
      color: Colors.red,
    );
  }
}
