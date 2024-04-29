import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';

class AlbumCreateDialog extends StatefulWidget {
  const AlbumCreateDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AlbumCreateState();
  }
}

class _AlbumCreateState extends State<AlbumCreateDialog> {
  final TextEditingController _textFieldController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDuplicate = false;

  void _showAlbumCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: AlertDialog(
              title: const Text("Create New Item"),
              content: _albumNameField(),
              actions: [
                ElevatedButton(
                  onPressed: _closeForm,
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Submit"),
                ),
              ],
            ),
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
      if (await AlbumManager.instance.createAlbum(albumName)) {
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
      decoration: const InputDecoration(labelText: "Album Name"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showAlbumCreateDialog,
      child: const Icon(Icons.add),
    );
  }
}
