import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';
import 'package:your_trip/fragments/album_card.dart';
import 'package:your_trip/fragments/album_create_dialog.dart';

class AlbumListView extends StatelessWidget {
  const AlbumListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: StreamBuilder(
          stream: AlbumManager.instance.liveAlbumList(),
          builder: (streamContext, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              if (data.isEmpty) {
                return const Card(
                  elevation: 5,
                  child: Center(
                    child: Text("No Albums"),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: data.length + 1,
                    itemBuilder: (listContext, index) {
                      if (index == data.length) {
                        return const SizedBox(
                          height: 70,
                        );
                      } else {
                        return AlbumCard(album: data[index]);
                      }
                    });
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: const AlbumCreateDialog(),
    );
  }
}
