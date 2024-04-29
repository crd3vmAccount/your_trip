import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';
import 'package:your_trip/fragments/album_edit_dialog.dart';
import 'package:your_trip/views/album/album_gallery_view.dart';
import 'package:your_trip/views/album/album_map_view.dart';

import '../data/album.dart';
import '../views/album/album_share_view.dart';

class AlbumCard extends StatefulWidget {
  final Album _album;

  const AlbumCard({required Album album, super.key}) : _album = album;

  @override
  State<StatefulWidget> createState() {
    return _AlbumCardState();
  }
}

class _AlbumCardState extends State<AlbumCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Text(
                    widget._album.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: _albumPreview()),
              ],
            ),
          ),
          _buttonColumn(
            () {
              pushRoute(context, AlbumMapView(album: widget._album));
            },
            () {
              pushRoute(context, AlbumGalleryView(album: widget._album));
            },
            () {
              pushRoute(context, AlbumShareView(album: widget._album));
            },
          ),
        ],
      ),
    );
  }

  Widget _albumPreview() {
    return widget._album.photos.isEmpty
        ? const SizedBox(
            height: 150,
            child: Center(
              child: Text(
                "No Images",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
          )
        : Center(
            child: FutureBuilder(
              future:
                  AlbumManager.instance.staticRandomPhotoBytes(widget._album),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error Retrieving Image: ${snapshot.error}");
                } else {
                  return snapshot.data == null
                      ? const Text("Image does not exist?")
                      : SizedBox(
                          width: double.infinity,
                          height: 200.0,
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: Image.memory(snapshot.data!),
                            ),
                          ),
                        );
                }
              },
            ),
          );
  }

  void pushRoute(BuildContext context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  Widget _buttonColumn(
    void Function() onMapClick,
    void Function() onGalleryClick,
    void Function() onShareClick,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: onMapClick,
          child: const Icon(Icons.map_outlined),
        ),
        ElevatedButton(
          onPressed: onGalleryClick,
          child: const Icon(Icons.auto_awesome_mosaic_rounded),
        ),
        if (!widget._album.isShared) ElevatedButton(
          onPressed: onShareClick,
          child: const Icon(Icons.share),
        ),
        if (!widget._album.isShared) AlbumEditDialog(album: widget._album),
      ],
    );
  }
}
