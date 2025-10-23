import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formState = GlobalKey<FormState>();
  bool _isLoginMode = true;
  String _enteredUsername = '';
  String _enteredEmail = '';
  String _enteredPassword = '';
  File? _selectedImage;
  bool _imageError = false;
  bool _isAuthenticating = false;

  void _submit() async {
    final isValid = _formState.currentState!.validate();
    if (!_isLoginMode && _selectedImage == null) {
      setState(() {
        _imageError = true;
      });
      return;
    } else if (_imageError) {
      setState(() {
        _imageError = false;
      });
    }

    if (!isValid) {
      return;
    }

    _formState.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (_isLoginMode) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);

        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'username': _enteredUsername,
              'email': _enteredEmail,
              'image_url': imageUrl,
            });

        FirebaseAuth.instance.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Failed.')),
      );
    }

    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Image.asset('assets/images/chat.png', width: 150),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formState,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLoginMode)
                          UserImagePicker(
                            onPickedImage: (File img) {
                              _selectedImage = img;
                              if (_imageError) {
                                setState(() {
                                  _imageError = false;
                                });
                              }
                            },
                          ),
                        if (_imageError)
                          Text(
                            'Please select a profile picture.',
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        if (!_isLoginMode)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              // TODO check unique
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 4) {
                                return 'Username must be at least 4 characters.';
                              }
                              if (value.contains(RegExp(r'[\s\t\n\r]'))) {
                                return 'Username cannot contain whitespace.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredUsername = newValue!;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email address';
                            }

                            value = value.trim();

                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );

                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }

                            // Additional checks
                            if (value.startsWith('.') || value.endsWith('.')) {
                              return 'Invalid email format';
                            }

                            if (value.contains('..')) {
                              return 'Invalid email format';
                            }

                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmail = newValue!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassword = newValue!;
                          },
                        ),
                        SizedBox(height: 12),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                            onPressed: _submit,
                            child: Text(
                              _isLoginMode ? 'Login' : 'Sign up',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                              });
                            },
                            child: Text(
                              _isLoginMode
                                  ? 'Create Account'
                                  : 'I have an account',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
