import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'album/album_list_view.dart';

RoundedRectangleBorder _buildCardBorder() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(6),
    side: const BorderSide(
      width: 2,
    ),
  );
}

Widget _formCard({required String title, required Widget form}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 20,
    ),
    child: Card(
      elevation: 5,
      shape: _buildCardBorder(),
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

Widget _cardPrompt({
  required String title,
  required String buttonText,
  required void Function() onPressed,
}) {
  return Card(
    elevation: 5,
    shape: _buildCardBorder(),
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

void _navigateToSignUpView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SignUpView(),
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

void _navigateToHomeView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AlbumListView(),
    ),
  );
}

Widget _formProgressIndicator() {
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

void _showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
  ));
}

Widget _formField({
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

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

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
            _formCard(title: 'Sign Up', form: const SignUpForm()),
            _cardPrompt(
              title: "Don't have an account?",
              buttonText: 'Sign In',
              onPressed: () {
                _navigateToSignInView(context);
              },
            ),
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
        ? _formProgressIndicator()
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
                      context: context,
                      controller: _emailController,
                      label: 'email',
                      validator: _validateEmail),
                  const SizedBox(height: 32),
                  _formField(
                    context: context,
                    controller: _passwordController,
                    label: 'password',
                    validator: _validatePassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 32),
                  _formField(
                    context: context,
                    controller: _confirmPasswordController,
                    label: 'confirm password',
                    validator: _validateConfirmPassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm(
                        onNavigate: () {
                          _showSnackBar(context, 'Signed Up');
                          _navigateToHomeView(context);
                        },
                        onValid: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            await FirebaseAuth.instance.signOut();
                          }

                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        },
                        onError: (e) {
                          var msg = e.toString();
                          if (msg.contains('email-already-in-use')) {
                            _showSnackBar(
                              context,
                              'Account already exists',
                              isError: true,
                            );
                          } else if (msg.contains('invalid-email')) {
                            _showSnackBar(
                              context,
                              'The provided email is not valid',
                              isError: true,
                            );
                          } else if (msg.contains('weak-password')) {
                            _showSnackBar(
                              context,
                              'The password is not strong enough',
                              isError: true,
                            );
                          } else {
                            _showSnackBar(
                              context,
                              'Failed to create account',
                              isError: true,
                            );
                          }
                        },
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
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

  Future<void> _submitForm({
    required void Function() onNavigate,
    required Future<void> Function() onValid,
    required void Function(Object e) onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await onValid();
        onNavigate();
      } catch (e) {
        onError(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _emailController.dispose();
  }
}

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
            _formCard(title: 'Sign In', form: const SignInForm()),
            _cardPrompt(
              title: "Don't have an account?",
              buttonText: 'Sign Up',
              onPressed: () => {
                _navigateToSignUpView(context),
              },
            )
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
        ? _formProgressIndicator()
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
                    context: context,
                    controller: _emailController,
                    label: 'email',
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 32),
                  _formField(
                    context: context,
                    controller: _passwordController,
                    label: 'password',
                    validator: _validatePassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm(
                        onValid: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            await FirebaseAuth.instance.signOut();
                            print('Signed out');
                            print(FirebaseAuth.instance.currentUser);
                          }
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          print(FirebaseAuth.instance.currentUser);

                        },
                        onNavigate: () {
                          print("Nav");
                          _navigateToHomeView(context);
                          _showSnackBar(context, 'Signed In');
                        },
                        onError: (e) {
                          _showSnackBar(
                            context,
                            'Incorrect Email or Password',
                            isError: true,
                          );
                        },
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _submitForm({
    required void Function() onNavigate,
    required Future<void> Function() onValid,
    required void Function(Object e) onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await onValid();
        onNavigate();
      } catch (e) {
        onError(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _emailController.dispose();
  }
}
