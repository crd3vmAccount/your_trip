import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    'Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
              () => {},
              () => {},
              () => {},
          ),
        ],
      ),
    );
  }

  Widget _buttonColumn(void Function() onMapClick,
      void Function() onGalleryClick,
      void Function() onShareClick,) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.map_outlined),
          onPressed: () {
            // Add your button functionality here
          },
        ),
        IconButton(
          icon: const Icon(Icons.auto_awesome_mosaic_rounded),
          onPressed: () {
            // Add your button functionality here
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Add your button functionality here
          },
        ),
      ],
    );
  }
}