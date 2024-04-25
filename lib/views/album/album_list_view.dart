import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';
import 'package:your_trip/fragments/album_card.dart';
import 'package:your_trip/fragments/album_create_dialog.dart';

import '../../data/album.dart';

class AlbumListView extends StatelessWidget {
  const AlbumListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
        actions: const [
          AlbumCreateDialog(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: FutureBuilder(
          future: AlbumManager.instance.staticList(),
          builder: (futureContext, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (listContext, index) {
                    Album album = snapshot.data![index];
                    return AlbumCard(title: album.displayName);
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
