import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'account_views.dart';
import 'album/album_list_view.dart';

RoundedRectangleBorder buildCardBorder() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(6),
    side: const BorderSide(
      width: 2,
    ),
  );
}

Widget formCard({required String title, required Widget form}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 20,
    ),
    child: Card(
      elevation: 5,
      shape: buildCardBorder(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
              ),
            ],
          ),
          form,
        ],
      ),
    ),
  );
}

Widget cardPrompt({
  required String title,
  required String buttonText,
  required void Function() onPressed,
}) {
  return Card(
    elevation: 5,
    shape: buildCardBorder(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Text(title),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          )
        ],
      ),
    ),
  );
}

void navigateToSignUpView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SignUpView(),
    ),
  );
}

void navigateToSignInView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SignInView(),
    ),
  );
}

void navigateToHomeView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AlbumListView(),
    ),
  );
}

Widget formProgressIndicator() {
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      child: const CircularProgressIndicator(),
    ),
  );
}

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
  ));
}

Widget formField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
  bool isPasswordField = false,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    obscureText: isPasswordField,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).secondaryHeaderColor.withOpacity(0.25),
    ),
  );
}