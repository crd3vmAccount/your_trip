import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_trip/views/gallery_list/gallery_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Column(
        children: [
          GalleryCard(),
        ],
      ),
    );
  }
}