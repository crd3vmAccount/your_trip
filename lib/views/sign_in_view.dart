import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import 'home_view.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Sign In"),
      ),
      body: Column(
        children: [signInCard()],
      ),
    );
  }

  Widget signInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(
            width: 2,
          ),
        ),
        child: const SignInForm(),
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: const CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            email: _emailController.text, password: _passwordController.text);
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
        context, MaterialPageRoute(builder: (context) => const HomeView()));
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

  Widget _formField(
      {required TextEditingController controller,
      required String label,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).secondaryHeaderColor.withOpacity(0.25),
      ),
    );
  }
}
