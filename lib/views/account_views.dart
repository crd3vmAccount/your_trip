import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'form_utilities.dart';

String? validateEmail(String? email) {
  if (email == null || !EmailValidator.validate(email)) {
    return 'Invalid email address.';
  } else {
    return null;
  }
}

String? validatePassword(String? password) {
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
            formCard(title: 'Sign Up', form: const SignUpForm()),
            cardPrompt(
              title: "Don't have an account?",
              buttonText: 'Sign In',
              onPressed: () {
                navigateToSignInView(context);
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
                      controller: _emailController,
                      label: 'email',
                      validator: validateEmail),
                  const SizedBox(height: 32),
                  formField(
                    context: context,
                    controller: _passwordController,
                    label: 'password',
                    validator: validatePassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 32),
                  formField(
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
                          showSnackBar(context, 'Signed Up');
                          navigateToHomeView(context);
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
                            showSnackBar(
                              context,
                              'Account already exists',
                              isError: true,
                            );
                          } else if (msg.contains('invalid-email')) {
                            showSnackBar(
                              context,
                              'The provided email is not valid',
                              isError: true,
                            );
                          } else if (msg.contains('weak-password')) {
                            showSnackBar(
                              context,
                              'The password is not strong enough',
                              isError: true,
                            );
                          } else {
                            showSnackBar(
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
            formCard(title: 'Sign In', form: const SignInForm()),
            cardPrompt(
              title: "Don't have an account?",
              buttonText: 'Sign Up',
              onPressed: () => {
                navigateToSignUpView(context),
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
                    controller: _emailController,
                    label: 'email',
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 32),
                  formField(
                    context: context,
                    controller: _passwordController,
                    label: 'password',
                    validator: validatePassword,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm(
                        onValid: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            await FirebaseAuth.instance.signOut();
                          }
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        },
                        onNavigate: () {
                          navigateToHomeView(context);
                          showSnackBar(context, 'Signed In');
                        },
                        onError: (e) {
                          showSnackBar(
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
