import 'package:flutter/material.dart';

class AlbumGalleryView extends StatefulWidget {
  const AlbumGalleryView({super.key});

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
        title: const Text("Album Title"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: buildGalleryGrid(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {  },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget buildGalleryGrid(BuildContext context) {
    return GridView.builder(
      itemCount: 10,
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
              color: Colors.grey,
            ));
      },
    );
  }
}