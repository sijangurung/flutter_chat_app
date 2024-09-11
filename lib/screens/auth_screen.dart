import 'dart:io';

import 'package:chat_app/model/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/providers/auth_providers.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:chat_app/notifiers/auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  File? _selectedImage;

  bool showImageMissingError = false;

  late final AuthNotifier _authNotifier =
      ref.read(authNotifierProvider.notifier);

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || (!_isLogin && _selectedImage == null)) {
      setState(() => showImageMissingError = _selectedImage == null);
      return; // show error...
    }

    _formKey.currentState!.save();

    if (_isLogin) {
      await _authNotifier.signIn(
          email: _enteredEmail, password: _enteredPassword);
    } else {
      await _authNotifier.signUp(
        username: _enteredUsername,
        email: _enteredEmail,
        password: _enteredPassword,
        imageFile: _selectedImage!,
      );
      // show confirmation...
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occurred, ${next.message} !')));
      }

      if (next is AuthLoading) {
        setState(() => _isLoading = true);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onImageSelected: (image) =>
                                  setState(() => _selectedImage = image),
                              hasError: showImageMissingError,
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters';
                                }
                                return null;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),
                          const SizedBox(height: 12),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  onPressed: _submit,
                                  child: Text(_isLogin ? 'Login' : 'Signup'),
                                ),
                          TextButton(
                            onPressed: () {
                              setState(() => _isLogin = !_isLogin);
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account. Login'),
                          ),
                        ],
                      )),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
