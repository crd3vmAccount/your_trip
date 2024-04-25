import 'package:flutter/material.dart';
import 'package:your_trip/views/album/album_gallery_view.dart';
import 'package:your_trip/views/album/album_map_view.dart';
import 'package:your_trip/views/album/album_share_view.dart';

import '../data/album.dart';

class AlbumCard extends StatelessWidget {
  final Album _album;

  const AlbumCard({required Album album, super.key}) : _album = album;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    _album.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(5, 3, 0, 0),
                    child: _albumPreview()),
              ],
            ),
          ),
          _buttonColumn(
            () {
              pushRoute(context, const AlbumMapView());
            },
            () {
              pushRoute(context, AlbumGalleryView(album: _album));
            },
            () {
              pushRoute(context, const AlbumShareView());
            },
          ),
        ],
      ),
    );
  }

  Widget _albumPreview() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey, // Placeholder for image
      child: _album.photos.isEmpty
          ? const Center(
              child: Text(
                "No Images",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            )
          : const Center(
              child: Text(
                "Has Images",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
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
      children: [
        ElevatedButton(
          onPressed: onMapClick,
          child: const Icon(Icons.map_outlined),
        ),
        ElevatedButton(
          onPressed: onGalleryClick,
          child: const Icon(Icons.auto_awesome_mosaic_rounded),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onShareClick,
        ),
      ],
    );
  }
}
