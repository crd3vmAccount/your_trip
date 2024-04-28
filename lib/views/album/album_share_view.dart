import 'package:flutter/material.dart';

import '../../data/album.dart';

class AlbumShareView extends StatefulWidget {
  final Album album;
  const AlbumShareView({required this.album, super.key});

  @override
  State createState() => _AlbumShareState();
}

class _AlbumShareState extends State<AlbumShareView> {
  final TextEditingController _emailController = TextEditingController();
  final List<String> _previousEmails = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share"),
      ),
      body: const Column(
        children: [
          Text("Blah")
        ],
      ),
    );
  }
}
