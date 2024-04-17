import 'package:flutter/material.dart';
import 'package:your_trip/views/album/album_card.dart';
import 'package:your_trip/views/album/album_create_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    var cardList = [
      AlbumCard(),
      AlbumCard(),
      AlbumCard(),
      AlbumCard(),
      AlbumCard(),
      AlbumCard(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
        actions: const [
          AlbumCreateDialog(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: ListView.builder(
            itemCount: cardList.length,
            itemBuilder: (context, index) {
              return cardList[index];
            }),
      ),
    );
  }
}