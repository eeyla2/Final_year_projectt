import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  //texteditingcontroller allows the writing of the text into another place once done
  //password and email declared
  late final TextEditingController _email;
  late final TextEditingController _password;

//overwriting initialization function to initialize email and password
//before use
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

//overwriting dispose function to dispose of the functions once done
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //create appbar instance for registerview that displays register
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            //display text field to enter email
            controller: _email, //control the text
            autocorrect: false, //properties of the email text
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              //display text inside textbox
              hintText: 'Enter email address',
            ),
          ),
          TextField(
              //display text field to enter email
              controller: _password, //control the text
              obscureText: true,
              enableSuggestions: false, //properties of the password text
              autocorrect: false,
              decoration: const InputDecoration(
                //display text inside textbox
                hintText: 'Enter password',
              )),
          TextButton(
            onPressed: () async {
              final email = _email
                  .text; //assigns the value of the email as the text entered to it
              final password = _password
                  .text; //assigns the value of the password as the text entered to it
              try {
                //try to register the user
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                devtools.log(userCredential.toString());
              } on FirebaseAuthException catch (e) {
                //if the exception FirebaseAuthException appears seremine type of Authexception
                if (e.code == 'weak-password') {
                  //if exception is weak-password print weak password in terminal
                  devtools.log('Weak Password');
                } else if (e.code == 'email-already-in-use') {
                  //if exception is email-already-in-use print email is already in use in terminal
                  devtools.log('Email is already in use');
                } else if (e.code == 'invalid-email') {
                  //if exception is invalid email print invalid email in terminal
                  devtools.log('invalid email was entered');
                } else {
                  devtools.log(e.toString());
                  devtools.log(e.code);
                }
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            //routes to login page if the button is pressed
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already registered? Login here!'),
          )
        ],
      ),
    );
  }
}
