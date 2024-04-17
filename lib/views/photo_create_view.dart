import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TakePhoto extends StatefulWidget {
  const TakePhoto({super.key});

  @override
  State createState() {
    return _TakePhotoState();
  }
}

class _TakePhotoState extends State<TakePhoto> {
  File? file;
  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            var image = await imagePicker.pickImage(source: ImageSource.camera);
            file = File(image!.path);
          },
          child: const Text('press me'),
        ),
        file != null
            ? Image.file(
          file!,
          fit: BoxFit.cover,
        )
            : const Text('no image selected')
      ],
    );
  }
}