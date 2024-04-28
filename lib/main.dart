import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:your_trip/views/account_views.dart';
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
          body: SignInView(),
        )),
  );
}
