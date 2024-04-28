import 'package:firebase_auth/firebase_auth.dart';
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
        title: Text(
          album.displayName,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            formCard(
              title: 'Share With',
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 16,
      ),
      child: Card(
        elevation: 5,
        shape: buildCardBorder(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Shared With"),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                stream: AlbumManager.instance.liveSharedWith(album),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text("Error: could not retrieve accounts.");
                  } else {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Text(
                        "Not shared with any accounts.",
                      );
                    } else {
                      return ShareList(
                        album: album,
                        accounts: snapshot.data!,
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShareList extends StatefulWidget {
  final Album album;
  final List<String> accounts;

  const ShareList({required this.album, required this.accounts, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShareListState();
  }
}

class _ShareListState extends State<ShareList> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            itemCount: widget.accounts.length,
            itemBuilder: (context, index) {
              if (widget.accounts.isEmpty) {
                return const Text(
                  "Not shared with any accounts.",
                );
              } else {
                return ListTile(
                  title: Text(widget.accounts[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await AlbumManager.instance.unshareWith(
                        widget.album,
                        widget.accounts[index],
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                );
              }
            },
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
    } else if (accountName == FirebaseAuth.instance.currentUser!.email) {
      return "Cannot share with self";
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
