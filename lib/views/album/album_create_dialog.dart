import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlbumCreateDialog extends StatefulWidget {
  const AlbumCreateDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AlbumCreateState();
  }
}

class _AlbumCreateState extends State<AlbumCreateDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  void _showAlbumCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter item name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                String newItemName = _textFieldController.text;
                print('New Item: $newItemName');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showAlbumCreateDialog,
      child: const Icon(Icons.add),
    );
  }
}
