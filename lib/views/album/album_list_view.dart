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
          child: StreamBuilder(
            stream: AlbumManager.instance.liveList(),
            builder: (streamContext, snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                var data = snapshot.data!;
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (listContext, index) {
                      return AlbumCard(album: data[index]);
                    }
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
      ),
    );
  }
}
