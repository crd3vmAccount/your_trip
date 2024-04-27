import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:your_trip/views/sign_up_view.dart';

import 'album/album_list_view.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Sign In",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            signInCard(),
            signUpCardPrompt(context),
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

  void _navigateToSignUpView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpView(),
      ),
    );
  }

  Widget signUpCardPrompt(BuildContext context) {
    return Card(
      elevation: 5,
      shape: _buildCardBorder(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            const Text("Don't have an account?"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => {_navigateToSignUpView(context)},
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }

  Widget signInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 20,
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
                    'Sign In',
                  ),
                ),
              ],
            ),
            SignInForm(),
          ],
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State createState() {
    return _SignInFormState();
  }
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 32),
                  _formField(
                    controller: _passwordController,
                    label: 'password',
                    validator: _validatePassword,
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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showSnackBar('Signed In');
        _navigateToHomeView();
      } catch (e) {
        _showSnackBar('Incorrect Email or Password', isError: true);
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
    _emailController.dispose();
  }
}
