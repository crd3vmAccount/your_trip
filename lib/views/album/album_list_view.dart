import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';
import 'package:your_trip/fragments/album_card.dart';
import 'package:your_trip/fragments/album_create_dialog.dart';

class AlbumListView extends StatefulWidget {
  const AlbumListView({super.key});

  @override
  State<StatefulWidget> createState() {
    return AlbumListState();
  }
}

class AlbumListState extends State<AlbumListView> {
  bool isShareView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  isShareView = !isShareView;
                });
              },
              child: isShareView
                  ? const Text("Your Albums")
                  : const Text("Friends' Albums"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: StreamBuilder(
          stream: isShareView
              ? AlbumManager.instance.liveSharedAlbumList()
              : AlbumManager.instance.liveAlbumList(),
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

      floatingActionButton: isShareView ? Container() :  const AlbumCreateDialog(),
    );
  }
}
