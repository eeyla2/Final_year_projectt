import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:legfree/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        //create appbar instance for loginview that displays login
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            //display text field to enter email
            controller: _email, //control the text
            autocorrect: false, //properties of text for email
            keyboardType:
                TextInputType.emailAddress, //special keyboard for email writing
            decoration: const InputDecoration(
              //display text inside textbox
              hintText: 'Enter email address',
            ),
          ),
          TextField(
            //display text field to enter email
            controller: _password, //control the text
            obscureText: true,
            enableSuggestions: false, //properties of text for password
            autocorrect: false,
            decoration: const InputDecoration(
              //display text inside textbox
              hintText: 'Enter password',
            ),
          ),
          TextButton(
            //display text button to store information and redirecting user
            onPressed: () async {
              final email = _email
                  .text; //assigns the value of the password as the text entered to it
              final password = _password
                  .text; //assigns the value of the email as the text entered to it

              try {
                //try to sign in the user
                final userCredential =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                print(userCredential);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/main/',
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                //if the exception FirebaseAuthException appears check for type of Authexception
                //general catch statement
                if (e.code == 'user-not-found') {
                  //if exception is user is not found print user not foundi in terminal
                  print('User not found');
                } else if (e.code == 'wrong-password') {
                  //if exception is wrong password entered print wrong password in terminal
                  print('Wrong password');
                } else {
                  print(e.code);
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            //routes to register page if button is pressed
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register/',
                (route) => false,
              );
            },
            child: const Text('Not registered? Register here'),
          )
        ],
      ),
    );
  }
}
