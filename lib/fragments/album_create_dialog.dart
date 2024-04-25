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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showAlbumCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Form(
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
        );
      },
    );
  }

  void _closeForm() {
    Navigator.of(context).pop();
    _textFieldController.clear();
  }

  void _submitForm() {
    var formState = _formKey.currentState;
    if (formState?.validate() ?? false) {
      Navigator.of(context).pop();
      _textFieldController.clear();
    }
  }

  Widget _albumNameField() {
    return TextFormField(
      controller: _textFieldController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Album name must not be blank";
        } else {
          return null;
        }
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
