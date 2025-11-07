import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormPage extends StatefulWidget {
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _food;
  String? _password;
  int? _nameLenght = 0;
  bool _showpassword = false;

  String? _validatetTextField(String fieldName, String? value, int lenght) {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Form Page"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person),
                  hintText: 'Your Name',
                  labelText: 'Name *',
                  suffixText: '$_nameLenght',
                ),
                onChanged: (String? value) {
                  setState(() {
                    _nameLenght = value!.length;
                  });
                },
                onSaved: (String? newValue) {
                  _name = newValue;
                },
                validator: (String? value) =>
                    _validatetTextField('Name', value, 1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.food_bank),
                  hintText: 'Favorite Food',
                  labelText: 'Food *',
                ),
                onSaved: (String? newValue) {
                  _food = newValue;
                },
                validator: (String? value) =>
                    _validatetTextField('Name', value, 1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: !_showpassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.security),
                  suffixIcon: GestureDetector(
                    onLongPress: () async {
                      setState(() {
                        _showpassword = true;
                      });

                      await Future.delayed(Duration(seconds: 5));

                      setState(() {
                        _showpassword = false;
                      });
                    },
                    child: Icon(Icons.remove_red_eye),
                  ),
                  hintText: 'Input your Password',
                  labelText: 'Password *',
                ),
                onSaved: (String? newValue) {
                  _password = newValue;
                },
                validator: (String? value) =>
                    _validatetTextField('Name', value, 7),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Input(s) is not valid')),
                  );

                  return;
                }

                _formKey.currentState!.save();
                var authMsg = "";
                try {
                  final credential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: _name!,
                        password: _password!,
                      );

                  authMsg = 'sign in success';
                } on FirebaseAuthException catch (e) {
                  authMsg = e.message!;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Hello $_name. You like to eat $_food. Auth - $authMsg',
                    ),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
