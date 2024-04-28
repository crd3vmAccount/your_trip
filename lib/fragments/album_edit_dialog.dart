import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';

import '../data/album.dart';

class AlbumEditDialog extends StatefulWidget {
  final Album album;

  const AlbumEditDialog({required this.album, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AlbumEditState();
  }
}

class _AlbumEditState extends State<AlbumEditDialog> {
  late final TextEditingController _textFieldController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    print(widget.album.displayName);
    _textFieldController = TextEditingController(
      text: widget.album.displayName,
    );
  }

  void _showAlbumCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            title: Text("Edit: ${widget.album.displayName}"),
            content: _albumNameField(),
            actions: [
              ElevatedButton(
                onPressed: _closeForm,
                child: const Icon(
                  color: Colors.red,
                  Icons.delete,
                ),
              ),
              ElevatedButton(
                onPressed: _closeForm,
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeForm() {
    _isDuplicate = false;
    _textFieldController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _submitForm() async {
    var formState = _formKey.currentState;
    if (formState?.validate() ?? false) {
      var albumName = _textFieldController.value.text;
      if (await AlbumManager.instance.renameAlbum(widget.album, albumName)) {
        _closeForm();
      } else {
        setState(() {
          _isDuplicate = true;
          formState?.validate();
        });
      }
    }
  }

  Widget _albumNameField() {
    return TextFormField(
      controller: _textFieldController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Album name must not be blank";
        } else if (value == widget.album.displayName) {
          return "Album already named that";
        } else if (_isDuplicate) {
          return "Album name already exists";
        } else {
          return null;
        }
      },
      onChanged: (value) {
        setState(() {
          _isDuplicate = false;
        });
      },
      decoration: const InputDecoration(labelText: "Name"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showAlbumCreateDialog,
      child: const Icon(Icons.edit),
    );
  }
}
