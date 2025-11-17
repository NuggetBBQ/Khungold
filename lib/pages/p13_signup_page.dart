import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/services/data_service.dart';
import 'package:lottie/lottie.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String? _nickname;
  bool _showpassword = false;
  bool _showconfirmPassword = false;

  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(context).colorScheme.onPrimary;

  String? _validatetTextField(String fieldName, String? value, int lenght) {
    if (value!.isEmpty) {
      return '$fieldName must not empty';
    }
    if (value.length <= lenght) {
      return '$fieldName must longer than $lenght char(s)';
    }
    return null;
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Lottie.network(
                  'https://lottie.host/5897da96-e7a4-4d9f-8ed1-87e0ca36fdd9/nNCfnVGSu0.json',
                  height: 200,
                ),
                SizedBox(height: 24),
                Text(
                  'Create your Account',
                  style: TextStyle(
                    color: onPrimaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    color: onPrimaryColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: onPrimaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              color: Colors.grey[700],
                            ),
                          ),
                          onSaved: (String? newValue) {
                            _email = newValue?.trim();
                            final email = _email ?? '';
                            final nick = email.contains('@')
                                ? email.split('@')[0]
                                : email;
                            setState(() {
                              _nickname = nick;
                            });
                          },
                          validator: (String? value) =>
                              _validatetTextField('Email', value, 1),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: onPrimaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          obscureText: !_showpassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[700],
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _showpassword = !_showpassword;
                                });
                              },
                              child: Icon(
                                _showpassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                          onChanged: (value) {
                            _password = value;
                          },
                          onSaved: (String? newValue) {
                            _password = newValue;
                          },
                          validator: (String? value) =>
                              _validatetTextField('Password', value, 7),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: onPrimaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          obscureText: !_showconfirmPassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[700],
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _showconfirmPassword = !_showconfirmPassword;
                                });
                              },
                              child: Icon(
                                _showconfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password must not empty';
                            }
                            if (value != _password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              34,
                              47,
                              43,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Input(s) is not valid'),
                                ),
                              );
                              return;
                            }
                            _formKey.currentState!.save();
                            var authMsg = "";
                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                    email: _email!,
                                    password: _password!,
                                  );
                              if (credential.user != null) {
                                final email = credential.user!.email ?? '';
                                final nickname = email.contains('@')
                                    ? email.split('@')[0]
                                    : email;
                                final meContact = Contact(
                                  id: credential.user!.uid,
                                  mainName: nickname,
                                  isMe: true,
                                );
                                await DataService.addContact(meContact);
                              }
                              if (mounted) {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/home');
                              }
                              return;
                              authMsg = 'Sign up success';
                            } on FirebaseAuthException catch (e) {
                              authMsg = e.message!;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Hello ${_nickname ?? _email} . Auth - $authMsg',
                                ),
                              ),
                            );
                          },
                          child: Text('Create Account!'),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: onPrimaryColor.withOpacity(0.8),
                            ),
                          ),
                          TextButton(
                            onPressed: _goToSignIn,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
