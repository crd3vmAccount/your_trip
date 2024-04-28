import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/location_manager.dart';

class AlbumMapView extends StatelessWidget {
  const AlbumMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album Title"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.camera_alt),
      ),
      body: const AlbumMapWidget(),
    );
  }
}

class AlbumMapWidget extends StatefulWidget {
  const AlbumMapWidget({super.key});

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
              ],
            );
          }
        });
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
