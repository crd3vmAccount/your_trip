import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_trip/views/sign_in_view.dart';

import 'album/album_list_view.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Sign Up",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            signUpCard(),
            signInCardPrompt(context)
          ],
        ),
      ),
    );
  }

  Widget signInCardPrompt(BuildContext context) {
    return Card(
      elevation: 5,
      shape: _buildCardBorder(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20 ),
        child: Column(
          children: [
            const Text("Already have an account?"),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () => { _navigateToSignInView(context) },
              child: const Text("Sign In"),
            )
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder _buildCardBorder() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: const BorderSide(
        width: 2,
      ),
    );
  }

  void _navigateToSignInView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInView(),
      ),
    );
  }

  Widget signUpCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        40,
        0,
        40,
        20,
      ),
      child: Card(
        elevation: 5,
        shape: _buildCardBorder(),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    "Sign Up",
                  ),
                ),
              ],
            ),
            SignUpForm()
          ],
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State createState() {
    return _SignUpFormState();
  }
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              child: const CircularProgressIndicator(),
            ),
          )
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
                  _formField(
                      controller: _emailController,
                      label: 'email',
                      validator: _validateEmail),
                  const SizedBox(height: 32),
                  _formField(
                    controller: _passwordController,
                    label: 'password',
                    validator: _validatePassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 32),
                  _formField(
                    controller: _confirmPasswordController,
                    label: 'confirm password',
                    validator: _validateConfirmPassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showSnackBar('Signed Up');
        _navigateToHomeView();
      } catch (e) {
        var msg = e.toString();
        if (msg.contains('email-already-in-use')) {
          _showSnackBar('Account already exists', isError: true);
        } else if (msg.contains('invalid-email')) {
          _showSnackBar('The provided email is not valid', isError: true);
        } else if (msg.contains('weak-password')) {
          _showSnackBar('The password is not strong enough', isError: true);
        } else {
          _showSnackBar('Failed to create account', isError: true);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToHomeView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AlbumListView(),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ));
  }

  String? _validateEmail(String? email) {
    if (email == null || !EmailValidator.validate(email)) {
      return 'Invalid email address.';
    } else {
      return null;
    }
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty || password.length < 6) {
      return 'Password must be 6 characters long.';
    } else {
      return null;
    }
  }

  String? _validateConfirmPassword(String? password) {
    if (password == null || password.isEmpty || password.length < 6) {
      return 'Password must be 6 characters long.';
    } else if (password != _passwordController.text) {
      return 'Confirmation password does not match';
    } else {
      return null;
    }
  }

  Widget _formField({
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

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
  }
}
