import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
        title: "Your Trip",
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Scaffold(
          body: TakePicture(),
        )),
  );
}

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State createState() {
    return _TakePictureState();
  }
}

class _TakePictureState extends State<TakePicture> {
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
