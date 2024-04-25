import 'package:flutter/material.dart';
import 'package:your_trip/views/album/album_gallery_view.dart';
import 'package:your_trip/views/album/album_map_view.dart';
import 'package:your_trip/views/album/album_share_view.dart';

class AlbumCard extends StatelessWidget {
  final String title;

  const AlbumCard({required this.title, super.key});

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
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 3, 0, 0),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey, // Placeholder for image
                  ),
                ),
              ],
            ),
          ),
          _buttonColumn(
            () {
              pushRoute(context, const AlbumMapView());
            },
            () {
              pushRoute(context, const AlbumGalleryView());
            },
            () {
              pushRoute(context, const AlbumShareView());
            },
          ),
        ],
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
