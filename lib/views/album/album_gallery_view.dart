import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:your_trip/data/album_manager.dart';

import '../../data/album.dart';

class AlbumGalleryView extends StatefulWidget {
  final Album _album;

  const AlbumGalleryView({required Album album, super.key}) : _album = album;

  @override
  State<StatefulWidget> createState() {
    return _AlbumGalleryState();
  }
}

class _AlbumGalleryState extends State<AlbumGalleryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._album.displayName),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: buildGalleryGrid(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> takePicture() async {
    final ImagePicker imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) await AlbumManager.instance.uploadImage(widget._album, image);
  }

  Widget buildGalleryGrid(BuildContext context) {
    return StreamBuilder(
      stream: AlbumManager.instance.livePhotos(widget._album),
      builder: (streamContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error!: ${snapshot.error}");
        } else {
          var images = snapshot.data!;
          return GridView.builder(
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    // Handle image tap
                  },
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.black38,
                    child: _imageFromBytes(images[index]),
                  ));
            },
          );
        }
      },
    );
  }

  Widget _imageFromBytes(Future<Uint8List?> bytes) {
    return FutureBuilder(
        future: bytes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return snapshot.data == null
                ? const Text("Image Failed to Load")
                : Image.memory(
                    snapshot.data!,
                    fit: BoxFit.fill,
                  );
          }
        });
  }
}
