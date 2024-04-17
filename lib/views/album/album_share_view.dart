import 'package:flutter/material.dart';

class AlbumShareView extends StatefulWidget {
  const AlbumShareView({super.key});

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
