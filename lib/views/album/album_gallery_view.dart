import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:your_trip/data/album_manager.dart';
import 'package:your_trip/views/photo_detail_view.dart';

import '../../data/album.dart';
import '../../data/photo.dart';

class AlbumGalleryView extends StatefulWidget {
  final Album _album;

  const AlbumGalleryView({required Album album, super.key}) : _album = album;

  @override
  State<StatefulWidget> createState() {
    return _AlbumGalleryState();
  }
}

class _AlbumGalleryState extends State<AlbumGalleryView> {
  bool _isLoading = false;
  Photo? _selectedPhoto;

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AlbumManager.instance.deletePhoto(
                  widget._album,
                  _selectedPhoto!,
                );
                setState(() {
                  _selectedPhoto = null;
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._album.displayName),
        actions: [
          if (_selectedPhoto != null)
            IconButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _buildGallery(),
      ),
      floatingActionButton: widget._album.isShared
          ? Container()
          : FloatingActionButton(
              onPressed: takePicture,
              child: const Icon(Icons.camera_alt),
            ),
    );
  }

  Future<void> takePicture() async {
    final ImagePicker imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _isLoading = true;
    });
    if (image != null) {
      await AlbumManager.instance.uploadImage(widget._album, image);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildGallery() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : StreamBuilder(
            stream: AlbumManager.instance.livePhotoWithBytes(widget._album),
            builder: (streamContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error!: ${snapshot.error}");
              } else {
                return _buildPhotoGrid(snapshot);
              }
            },
          );
  }

  Widget _buildPhotoGrid(AsyncSnapshot<List<Future<Photo>>> snapshot) {
    var photos = snapshot.data!;
    if (photos.isEmpty) {
      return const Card(
        elevation: 5,
        child: Center(
          child: Text("No photos"),
        ),
      );
    } else {
      return GridView.builder(
        itemCount: photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            height: 100,
            color: Colors.black38,
            child: _imageFromBytes(photos[index]),
          );
        },
      );
    }
  }

  Widget _imageFromBytes(Future<Photo> futurePhoto) {
    return FutureBuilder(
      future: futurePhoto,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return snapshot.data == null || snapshot.data!.bytes == null
              ? const Text("Image Failed to Load")
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoDetailView(imageBytes: snapshot.data!.bytes!),
                      ),
                    );
                  },
                  onLongPress: () {
                    setState(() {
                      if (_selectedPhoto == snapshot.data!) {
                        _selectedPhoto = null;
                      } else {
                        _selectedPhoto = snapshot.data!;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: _selectedPhoto == snapshot.data!
                              ? Colors.red
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.memory(
                        snapshot.data!.bytes!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
        }
      },
    );
  }
}
