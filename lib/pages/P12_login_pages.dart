import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khungold/pages/p00_home_page.dart';
import 'package:khungold/pages/p13_signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String? _nickname;
  bool _showpassword = false;

  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(context).colorScheme.onPrimary;

  String? _validateTextField(String fieldName, String? value, int lenght) {
    if (value!.isEmpty) {
      return '$fieldName must not empty';
    }

    if (value.length <= lenght) {
      return '$fieldName must longer than $lenght char(s)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimaryColor),
          onPressed: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => SignupPage()));
          },
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
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
                SizedBox(height: 24),
                Text(
                  'Sign in to your Account',
                  style: TextStyle(
                    color: onPrimaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back, you\'ve been missed!',
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
                              _validateTextField('Name', value, 1),
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
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showpassword = !_showpassword;
                                });
                              },
                              icon: Icon(
                                _showpassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          onSaved: (String? newValue) {
                            _password = newValue;
                          },
                          validator: (String? value) =>
                              _validateTextField('Password', value, 7),
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
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

                            try {
                              final credential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                    email: _email!,
                                    password: _password!,
                                  );

                              if (credential.user != null) {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/home');
                              }
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign In Failed: ${e.message}'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'An unexpected error occurred: $e',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text('Sign In'),
                        ),
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
