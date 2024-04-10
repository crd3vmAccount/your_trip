import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HomeView());
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Test'),
        ),
        body: Column(
          children: [
            TextButton(
                onPressed: () async {
                  var instance = FirebaseAuth.instance;
                  var creds = instance.createUserWithEmailAndPassword(
                      email: "bob@gmail.com",
                      password: "hellofdf"
                  );
                  print(creds);
                },
                child: const Text('Press Me'))
          ],
        ),
      ),
    );
  }
}
