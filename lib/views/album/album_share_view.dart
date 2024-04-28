import 'package:flutter/material.dart';
import 'package:your_trip/data/album_manager.dart';

import '../../data/album.dart';
import '../form_utilities.dart';

class AlbumShareView extends StatelessWidget {
  final Album album;

  const AlbumShareView({required this.album, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Share",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            formCard(
              title: 'Share Album',
              form: ShareAlbumForm(
                album: album,
              ),
            ),
            accountListCards(),
          ],
        ),
      ),
    );
  }

  Widget accountListCards() {
    return Card(
      elevation: 5,
      shape: buildCardBorder(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Shared With"),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class ShareAlbumForm extends StatefulWidget {
  final Album album;

  const ShareAlbumForm({required this.album, super.key});

  @override
  State createState() {
    return _ShareAlbumFormState();
  }
}

class _ShareAlbumFormState extends State<ShareAlbumForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  bool _isLoading = false;

  String? _validateAccountName(String? accountName) {
    if (accountName == null || accountName.isEmpty) {
      return "Name must not be blank";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? formProgressIndicator()
        : Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  formField(
                    context: context,
                    controller: _accountController,
                    label: 'account name',
                    validator: _validateAccountName,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        await AlbumManager.instance
                            .shareWith(widget.album, _accountController.text);
                        _accountController.text = "";
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    _accountController.dispose();
  }
}
