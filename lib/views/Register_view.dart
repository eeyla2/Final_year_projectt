import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legsfree/services/auth/auth_exceptions.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'package:legsfree/utilities/show_error_dialog.dart';
//import 'dart:developer' as devtools show log;

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
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.android,
                size: 100,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text(
                  'You look lost...',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 30,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(),
                child: Text(
                  'Don\'t worry you are in the right place!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Register with a new account',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    //display text field to enter email
                    controller: _email, //control the text
                    autocorrect: false, //properties of the email text
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      //display text inside textbox
                      hintText: 'Enter email address',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                      //display text field to enter email
                      controller: _password, //control the text
                      obscureText: true,
                      enableSuggestions:
                          false, //properties of the password text
                      autocorrect: false,
                      decoration: const InputDecoration(
                        //display text inside textbox
                        hintText: 'Enter password',
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 140.0, right: 140.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final email = _email
                          .text; //assigns the value of the email as the text entered to it
                      final password = _password
                          .text; //assigns the value of the password as the text entered to it
                      try {
                        //try to register the user
                        await AuthService.firebase().createUser(
                          email: email,
                          password: password,
                        );
                        AuthService.firebase().sendEmailVerification();
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                        }); //push and don't remove
                      } on WeakPasswordAuthException {
                        //if exception is weak-password print weak password in terminal
                        await showErrorDialog(context, 'Weak password');
                      } on EmailAlreadyInUseAuthException {
                        //if exception is email-already-in-use print email is already in use in terminal
                        await showErrorDialog(context,
                            'Email is already in use, try a different email');
                      } on InvalidEmailAuthException {
                        //if exception is invalid email print invalid email in terminal
                        await showErrorDialog(context,
                            'Invalid email entered, try a different email');
                      } on GenericAuthException {
                        await showErrorDialog(context, 'Failed to register');
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                //routes to login page if the button is pressed
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Already registered? Login here!',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
